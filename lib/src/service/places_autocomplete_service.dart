import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:places_autocomplete/src/models/place_details.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/models/places_location_bias.dart';
import 'package:places_autocomplete/src/models/places_location_restriction.dart';
import 'package:places_autocomplete/src/models/places_origin.dart';

/// Low-level HTTP client for the Google Places API (New).
///
/// Use PlacesAutocompleteController for the full debounced, cached
/// autocomplete experience. This class is exposed for testing and
/// advanced use cases.
class PlacesAutocompleteService {
  /// Creates a [PlacesAutocompleteService] with the given [apiKey].
  ///
  /// An optional [httpClient] can be provided for testing.
  PlacesAutocompleteService({required this.apiKey, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _autocompleteUrl =
      'https://places.googleapis.com/v1/places:autocomplete';
  static const _detailsBaseUrl = 'https://places.googleapis.com/v1/places';

  /// Google Places API key used in request headers.
  final String apiKey;
  final http.Client _httpClient;

  /// Fetches autocomplete predictions for [query].
  ///
  /// Throws [PlacesServiceException] on any non-200 response.
  Future<List<PlacePrediction>> fetchSuggestions({
    required String query,
    required String sessionToken,
    List<String>? countries,
    List<String>? includedPrimaryTypes,
    PlacesLocationBias? locationBias,
    PlacesLocationRestriction? locationRestriction,
    PlacesOrigin? origin,
    String? languageCode,
    int maxResults = 5,
  }) async {
    assert(
      locationBias == null || locationRestriction == null,
      'Cannot use both locationBias and locationRestriction.',
    );

    final body = <String, dynamic>{
      'input': query,
      'sessionToken': sessionToken,
    };

    if (countries != null && countries.isNotEmpty) {
      body['includedRegionCodes'] = countries;
    }
    if (includedPrimaryTypes != null && includedPrimaryTypes.isNotEmpty) {
      body['includedPrimaryTypes'] = includedPrimaryTypes;
    }
    if (locationBias != null) {
      body['locationBias'] = locationBias.toJson();
    }
    if (locationRestriction != null) {
      body['locationRestriction'] = locationRestriction.toJson();
    }
    if (origin != null) {
      body['origin'] = origin.toJson();
    }
    if (languageCode != null) {
      body['languageCode'] = languageCode;
    }

    final response = await _httpClient.post(
      Uri.parse(_autocompleteUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': [
          'suggestions.placePrediction.placeId',
          'suggestions.placePrediction.place',
          'suggestions.placePrediction.text',
          'suggestions.placePrediction.structuredFormat',
          'suggestions.placePrediction.types',
          'suggestions.placePrediction.distanceMeters',
        ].join(','),
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw PlacesServiceException(
        'Autocomplete request failed with status '
        '${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final suggestions = json['suggestions'] as List<dynamic>? ?? [];

    return suggestions
        .where(
          (s) => (s as Map<String, dynamic>).containsKey('placePrediction'),
        )
        .map((s) => PlacePrediction.fromJson(s as Map<String, dynamic>))
        .take(maxResults)
        .toList();
  }

  /// Fetches full place details for [placeId].
  ///
  /// Throws [PlacesServiceException] on any non-200 response.
  Future<PlaceDetails> fetchDetails({
    required String placeId,
    required String sessionToken,
  }) async {
    final response = await _httpClient.get(
      Uri.parse('$_detailsBaseUrl/$placeId'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': '*',
        'X-Goog-Session-Token': sessionToken,
      },
    );

    if (response.statusCode != 200) {
      throw PlacesServiceException(
        'Place details request failed with status '
        '${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceDetails.fromJson(json);
  }
}

/// Exception thrown by [PlacesAutocompleteService] on API errors.
class PlacesServiceException implements Exception {
  /// Creates a [PlacesServiceException] with the given [message].
  const PlacesServiceException(this.message);

  /// Human-readable description of the API error.
  final String message;

  @override
  String toString() => 'PlacesServiceException: $message';
}
