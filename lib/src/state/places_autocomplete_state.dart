import 'package:places_autocomplete/src/models/place_prediction.dart';

/// Base class for all autocomplete states emitted by
/// PlacesAutocompleteController.
sealed class PlacesAutocompleteState {
  /// Creates a [PlacesAutocompleteState].
  const PlacesAutocompleteState();
}

/// The controller is idle — no search has been triggered.
class PlacesStateIdle extends PlacesAutocompleteState {
  /// Creates a [PlacesStateIdle].
  const PlacesStateIdle();
}

/// A network request is in flight.
class PlacesStateLoading extends PlacesAutocompleteState {
  /// Creates a [PlacesStateLoading].
  const PlacesStateLoading();
}

/// The request completed successfully but returned no predictions.
class PlacesStateEmpty extends PlacesAutocompleteState {
  /// Creates a [PlacesStateEmpty].
  const PlacesStateEmpty();
}

/// The request failed with an error.
class PlacesStateError extends PlacesAutocompleteState {
  /// Creates a [PlacesStateError] wrapping the given [error].
  const PlacesStateError(this.error);

  /// The error that caused the failure.
  final Object error;
}

/// The request completed and returned one or more predictions.
class PlacesStateResults extends PlacesAutocompleteState {
  /// Creates a [PlacesStateResults] with the given [predictions].
  const PlacesStateResults(this.predictions);

  /// The list of place predictions returned by the API.
  final List<PlacePrediction> predictions;
}
