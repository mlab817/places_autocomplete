import 'package:flutter/material.dart';

import 'package:places_autocomplete/src/controller/places_autocomplete_controller.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/widgets/display_mode.dart';
import 'package:places_autocomplete/src/widgets/places_autocomplete_mixin.dart';

/// A [FormField]-wrapped autocomplete text field for use inside a [Form].
///
/// Exposes a [validator] that receives both the raw text and the selected
/// [PlacePrediction], enabling flexible validation strategies.
class PlacesAutocompleteTextFormField extends StatefulWidget {
  /// Creates a [PlacesAutocompleteTextFormField].
  const PlacesAutocompleteTextFormField({
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
    this.validator,
    this.autovalidateMode,
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

  /// Validates the field; receives the raw text and the selected prediction.
  ///
  /// Return a non-null string to show a validation error.
  final String? Function(String? value, PlacePrediction? prediction)? validator;

  /// When to run validation automatically.
  final AutovalidateMode? autovalidateMode;

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
  State<PlacesAutocompleteTextFormField> createState() =>
      _PlacesAutocompleteTextFormFieldState();
}

class _PlacesAutocompleteTextFormFieldState
    extends State<PlacesAutocompleteTextFormField>
    with PlacesAutocompleteMixin {
  // tracks the selected prediction for validation
  PlacePrediction? _selectedPrediction;
  final _formFieldKey = GlobalKey<FormFieldState<PlacePrediction>>();

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
  void handleSelected(PlacePrediction prediction) {
    // track selected prediction for validator
    setState(() => _selectedPrediction = prediction);
    super.handleSelected(prediction);
  }

  // reset selected prediction when text changes
  @override
  void initState() {
    super.initState();
    textController.addListener(_onTextChangedForValidation);
  }

  void _onTextChangedForValidation() {
    // if user types after selecting, clear the prediction
    if (_selectedPrediction != null &&
        textController.text != _selectedPrediction!.description) {
      setState(() => _selectedPrediction = null);
    }

    // trigger autovalidation on text change
    _formFieldKey.currentState?.validate();
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChangedForValidation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FormField<PlacePrediction>(
            key: _formFieldKey,
            autovalidateMode: widget.autovalidateMode,
            validator: (_) => widget.validator?.call(
              textController.text,
              _selectedPrediction,
            ),
            builder: (FormFieldState<PlacePrediction> formState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    focusNode: focusNode,
                    autofocus: widget.autofocus,
                    enabled: widget.enabled,
                    style: widget.style,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    decoration: (widget.decoration ??
                            const InputDecoration(
                              hintText: 'Search places...',
                              prefixIcon: Icon(Icons.search),
                            ))
                        .copyWith(errorText: formState.errorText),
                  ),
                  if (widget.displayMode == DisplayMode.inline)
                    buildInlineSuggestions(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
