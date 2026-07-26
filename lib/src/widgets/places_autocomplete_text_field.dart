import 'package:flutter/material.dart';

import 'package:places_autocomplete/src/controller/places_autocomplete_controller.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/widgets/display_mode.dart';
import 'package:places_autocomplete/src/widgets/places_autocomplete_mixin.dart';

/// A [TextField] wired up for Google Places Autocomplete.
///
/// Shows suggestions as an overlay (default) or inline below the field.
class PlacesAutocompleteTextField extends StatefulWidget {
  /// Creates a [PlacesAutocompleteTextField].
  const PlacesAutocompleteTextField({
    required this.controller,
    required this.onSelected,
    super.key,
    this.decoration,
    this.displayMode = DisplayMode.overlay,
    this.maxResults = 5,
    this.maxSuggestionsHeight = 200.0,
    this.overlayOffset = const Offset(0, 4),
    this.itemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.initialValue,
    this.onChanged,
    this.style,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
  });

  /// The controller that manages the autocomplete session.
  final PlacesAutocompleteController controller;

  /// Decoration applied to the underlying [TextField].
  final InputDecoration? decoration;

  /// Whether suggestions appear as an overlay or inline.
  final DisplayMode displayMode;

  /// Maximum number of suggestions to show.
  final int maxResults;

  /// Maximum height of the suggestions list.
  final double maxSuggestionsHeight;

  /// Pixel offset of the overlay relative to the text field.
  final Offset overlayOffset;

  /// Custom builder for each suggestion row.
  final Widget Function(BuildContext, PlacePrediction)? itemBuilder;

  /// Custom builder for the loading state.
  final Widget Function(BuildContext)? loadingBuilder;

  /// Custom builder shown when no results are found.
  final Widget Function(BuildContext)? emptyBuilder;

  /// Custom builder shown on request failure.
  final Widget Function(BuildContext, Object)? errorBuilder;

  /// Called when the user selects a suggestion.
  final void Function(PlacePrediction) onSelected;

  /// Initial text to pre-populate the field with.
  final String? initialValue;

  /// Called on every text change.
  final ValueChanged<String>? onChanged;

  /// Text style for the field.
  final TextStyle? style;

  /// Keyboard type for the field.
  final TextInputType? keyboardType;

  /// Keyboard action button type.
  final TextInputAction? textInputAction;

  /// Whether to request focus automatically on build.
  final bool autofocus;

  /// Whether the field is interactive.
  final bool enabled;

  @override
  State<PlacesAutocompleteTextField> createState() =>
      _PlacesAutocompleteTextFieldState();
}

class _PlacesAutocompleteTextFieldState
    extends State<PlacesAutocompleteTextField> with PlacesAutocompleteMixin {
  @override
  PlacesAutocompleteController get controller => widget.controller;

  @override
  DisplayMode get displayMode => widget.displayMode;

  @override
  double get maxSuggestionsHeight => widget.maxSuggestionsHeight;

  @override
  Offset get overlayOffset => widget.overlayOffset;

  @override
  int get maxResults => widget.maxResults;

  @override
  void Function(PlacePrediction) get onSelected => widget.onSelected;

  @override
  Widget Function(BuildContext, PlacePrediction)? get itemBuilder =>
      widget.itemBuilder;

  @override
  Widget Function(BuildContext)? get loadingBuilder => widget.loadingBuilder;

  @override
  Widget Function(BuildContext)? get emptyBuilder => widget.emptyBuilder;

  @override
  Widget Function(BuildContext, Object)? get errorBuilder =>
      widget.errorBuilder;

  @override
  String? get initialValue => widget.initialValue;

  @override
  ValueChanged<String>? get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            focusNode: focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            style: widget.style,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            decoration: widget.decoration ??
                const InputDecoration(
                  hintText: 'Search places...',
                  prefixIcon: Icon(Icons.search),
                ),
          ),
          if (widget.displayMode == DisplayMode.inline)
            buildInlineSuggestions(),
        ],
      ),
    );
  }
}
