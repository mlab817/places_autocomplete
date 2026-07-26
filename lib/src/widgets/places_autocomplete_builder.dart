import 'package:flutter/material.dart';

import 'package:places_autocomplete/src/controller/places_autocomplete_controller.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/state/places_autocomplete_state.dart';

/// A widget that exposes the autocomplete state via a builder callback,
/// letting callers render any custom UI.
class PlacesAutocompleteBuilder extends StatefulWidget {
  /// Creates a [PlacesAutocompleteBuilder].
  const PlacesAutocompleteBuilder({
    required this.controller,
    required this.onSelected,
    required this.builder,
    super.key,
  });

  /// The controller that drives this builder's state.
  final PlacesAutocompleteController controller;

  /// Called when the user selects a prediction. Receives the selected
  /// [PlacePrediction] after the controller state is reset to idle.
  final void Function(PlacePrediction prediction) onSelected;

  /// Builder receives the current [PlacesAutocompleteState] and an
  /// [onSelected] callback. Call [onSelected] with a prediction to trigger
  /// selection — it resets the controller state and invokes [onSelected].
  final Widget Function(
    BuildContext context,
    PlacesAutocompleteState state,
    void Function(PlacePrediction prediction) onSelected,
  ) builder;

  @override
  State<PlacesAutocompleteBuilder> createState() =>
      _PlacesAutocompleteBuilderState();
}

class _PlacesAutocompleteBuilderState extends State<PlacesAutocompleteBuilder> {
  @override
  void initState() {
    super.initState();
    widget.controller.stateNotifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    widget.controller.stateNotifier.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() => setState(() {});

  void _handleSelected(PlacePrediction prediction) {
    widget.controller.reset();
    widget.onSelected(prediction);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.controller.state, _handleSelected);
  }
}
