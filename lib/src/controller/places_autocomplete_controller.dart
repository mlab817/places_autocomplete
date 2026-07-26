import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:places_autocomplete/src/models/place_details.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/models/places_location_bias.dart';
import 'package:places_autocomplete/src/models/places_location_restriction.dart';
import 'package:places_autocomplete/src/models/places_origin.dart';
import 'package:places_autocomplete/src/service/places_autocomplete_service.dart';
import 'package:places_autocomplete/src/state/places_autocomplete_state.dart';
import 'package:uuid/uuid.dart';

/// Controls the state and behavior of a Google Places Autocomplete session.
///
/// Manages debouncing, caching, session tokens, and state transitions for
/// a places autocomplete text field.
class PlacesAutocompleteController {
  /// Creates a [PlacesAutocompleteController].
  ///
  /// The [apiKey] must be a valid Google Places API key.
  /// Only one of [locationBias] or [locationRestriction] may be provided.
  PlacesAutocompleteController({
    required this.apiKey,
    this.debounceTime = const Duration(milliseconds: 600),
    this.cacheTTL = const Duration(minutes: 5),
    this.countries,
    this.includedPrimaryTypes,
    this.locationBias,
    this.locationRestriction,
    this.origin,
    this.languageCode,
    this.maxResults = 5,
    http.Client? httpClient,
  })  : assert(
          locationBias == null || locationRestriction == null,
          'Cannot use both locationBias and locationRestriction.',
        ),
        assert(
          maxResults >= 1 && maxResults <= 5,
          'maxResults must be between 1 and 5.',
        ) {
    _service = PlacesAutocompleteService(
      apiKey: apiKey,
      httpClient: httpClient,
    );
    _stateNotifier = ValueNotifier(const PlacesStateIdle());
  }

  /// Google Places API key used for all requests.
  final String apiKey;

  /// Duration to wait after the last keystroke before sending a request.
  final Duration debounceTime;

  /// How long to keep prediction results in the in-memory cache.
  final Duration cacheTTL;

  /// ISO 3166-1 alpha-2 country codes to restrict results to.
  final List<String>? countries;

  /// Primary place types to restrict autocomplete results to.
  final List<String>? includedPrimaryTypes;

  /// Geographic area to bias results toward without strictly restricting them.
  final PlacesLocationBias? locationBias;

  /// Geographic area to strictly restrict results to.
  final PlacesLocationRestriction? locationRestriction;

  /// Point from which straight-line distances to predictions are calculated.
  final PlacesOrigin? origin;

  /// BCP-47 language code for returned results.
  final String? languageCode;

  /// Maximum number of predictions to return (1–5).
  final int maxResults;

  // internals
  late final PlacesAutocompleteService _service;
  late final ValueNotifier<PlacesAutocompleteState> _stateNotifier;
  final Map<String, _CacheEntry> _cache = {};
  Timer? _debounceTimer;
  String _sessionToken = const Uuid().v4();
  bool _isDisposed = false;

  /// The [ValueNotifier] that broadcasts state changes to listeners.
  ValueNotifier<PlacesAutocompleteState> get stateNotifier => _stateNotifier;

  /// The current autocomplete state.
  PlacesAutocompleteState get state => _stateNotifier.value;

  /// Triggers a debounced search for [query].
  ///
  /// Resets state to [PlacesStateIdle] when [query] is empty or whitespace.
  void search(String query) {
    // cancel previous debounce
    _debounceTimer?.cancel();

    // reset to idle on empty query
    if (query.trim().isEmpty) {
      _stateNotifier.value = const PlacesStateIdle();
      return;
    }

    // debounce
    _debounceTimer = Timer(debounceTime, () => _fetch(query.trim()));
  }

  /// Fetches full [PlaceDetails] for the given [placeId].
  ///
  /// Resets the session token after the call so that the next autocomplete
  /// session is billed separately.
  Future<PlaceDetails> fetchDetails(String placeId) async {
    final details = await _service.fetchDetails(
      placeId: placeId,
      sessionToken: _sessionToken,
    );

    // reset session token after details fetch
    // so next autocomplete session is billed separately
    _resetSessionToken();

    return details;
  }

  /// Clears all in-memory cached predictions.
  void clearCache() => _cache.clear();

  /// Cancels any pending debounce and resets the state to [PlacesStateIdle].
  void reset() {
    _debounceTimer?.cancel();
    _stateNotifier.value = const PlacesStateIdle();
  }

  /// Cancels any pending debounce timer without changing the state.
  void cancelDebounce() {
    _debounceTimer?.cancel();
  }

  /// Releases all resources held by this controller.
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _stateNotifier.dispose();
    _cache.clear();
  }

  // private
  Future<void> _fetch(String query) async {
    // check cache
    final cached = _cache[query];
    if (cached != null && !cached.isExpired(cacheTTL)) {
      if (_isDisposed) return;
      _stateNotifier.value = cached.predictions.isEmpty
          ? const PlacesStateEmpty()
          : PlacesStateResults(cached.predictions);
      return;
    }

    // fetch
    if (_isDisposed) return;
    _stateNotifier.value = const PlacesStateLoading();

    try {
      final predictions = await _service.fetchSuggestions(
        query: query,
        sessionToken: _sessionToken,
        countries: countries,
        includedPrimaryTypes: includedPrimaryTypes,
        locationBias: locationBias,
        locationRestriction: locationRestriction,
        origin: origin,
        languageCode: languageCode,
        maxResults: maxResults,
      );

      // cache results
      _cache[query] = _CacheEntry(
        predictions: predictions,
        cachedAt: DateTime.now(),
      );

      if (_isDisposed) return;
      _stateNotifier.value = predictions.isEmpty
          ? const PlacesStateEmpty()
          : PlacesStateResults(predictions);
    } on Exception catch (e) {
      if (_isDisposed) return;
      _stateNotifier.value = PlacesStateError(e);
    }
  }

  void _resetSessionToken() {
    _sessionToken = const Uuid().v4();
  }
}

// cache entry
class _CacheEntry {
  const _CacheEntry({required this.predictions, required this.cachedAt});

  final List<PlacePrediction> predictions;
  final DateTime cachedAt;

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}
