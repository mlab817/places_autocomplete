import 'package:flutter/material.dart';

import 'package:places_autocomplete/src/controller/places_autocomplete_controller.dart';
import 'package:places_autocomplete/src/models/place_prediction.dart';
import 'package:places_autocomplete/src/state/places_autocomplete_state.dart';
import 'package:places_autocomplete/src/widgets/display_mode.dart';

/// Shared behavior for autocomplete text field widgets.
///
/// Mix this into a [State] to get keyboard, focus, overlay, and suggestion
/// list management for free.
mixin PlacesAutocompleteMixin<T extends StatefulWidget> on State<T> {
  // these must be provided by the widget using this mixin

  /// The controller that drives the autocomplete session.
  PlacesAutocompleteController get controller;

  /// Whether suggestions float as an overlay or push content inline.
  DisplayMode get displayMode;

  /// Maximum height for the suggestions list widget.
  double get maxSuggestionsHeight;

  /// Pixel offset applied to the overlay relative to the text field.
  Offset get overlayOffset;

  /// Maximum number of predictions to display.
  int get maxResults;

  /// Called when the user taps a suggestion.
  void Function(PlacePrediction) get onSelected;

  /// Optional builder for each suggestion item.
  Widget Function(BuildContext, PlacePrediction)? get itemBuilder;

  /// Optional builder shown while predictions are loading.
  Widget Function(BuildContext)? get loadingBuilder;

  /// Optional builder shown when no predictions are found.
  Widget Function(BuildContext)? get emptyBuilder;

  /// Optional builder shown when the request fails.
  Widget Function(BuildContext, Object)? get errorBuilder;

  /// Initial text to populate the text field with.
  String? get initialValue;

  /// Called whenever the text field value changes.
  ValueChanged<String>? get onChanged;

  // internals

  /// Text controller bound to the autocomplete text field.
  final TextEditingController textController = TextEditingController();

  /// Focus node bound to the autocomplete text field.
  final FocusNode focusNode = FocusNode();

  /// Layer link used to anchor the overlay to the text field.
  final LayerLink layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Set initial text before adding the listener so it doesn't
    // trigger a search.
    final initial = initialValue ?? '';
    if (initial.isNotEmpty) textController.text = initial;
    textController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
    controller.stateNotifier.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    controller.stateNotifier.removeListener(_onStateChanged);
    controller.cancelDebounce();
    textController.dispose();
    focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  // listeners
  void _onTextChanged() {
    controller.search(textController.text);
    onChanged?.call(textController.text);
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onStateChanged() {
    final state = controller.state;

    if (!focusNode.hasFocus) return;

    if (state is PlacesStateIdle) {
      _removeOverlay();
      return;
    }

    if (displayMode == DisplayMode.overlay) {
      _updateOverlay();
    } else {
      // inline — just rebuild
      setState(() {});
    }
  }

  // selection

  /// Handles a prediction selection: populates the text field,
  /// closes the overlay, and calls [onSelected].
  void handleSelected(PlacePrediction prediction) {
    textController.text = prediction.description;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: prediction.description.length),
    );
    _removeOverlay();
    focusNode.unfocus();
    controller.reset();
    onSelected(prediction);
  }

  // overlay
  void _updateOverlay() {
    _removeOverlay();

    final state = controller.state;
    if (state is PlacesStateIdle) return;

    // Capture the text field width now, while we still have the widget's
    // own BuildContext. Inside OverlayEntry.builder the context belongs to
    // the Overlay, so findRenderObject() there returns the wrong box.
    final renderBox = context.findRenderObject() as RenderBox?;
    final textFieldWidth = renderBox?.size.width ?? 200;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        width: textFieldWidth,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: overlayOffset,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxSuggestionsHeight),
              child: buildSuggestionsList(state),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // suggestions list builder

  /// Builds the appropriate suggestions widget for the given [state].
  Widget buildSuggestionsList(PlacesAutocompleteState state) {
    return switch (state) {
      PlacesStateLoading() => _buildLoading(),
      PlacesStateEmpty() => _buildEmpty(),
      PlacesStateError(error: final e) => _buildError(e),
      PlacesStateResults(predictions: final predictions) => _buildResults(
          predictions,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildLoading() {
    return loadingBuilder?.call(context) ??
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
  }

  Widget _buildEmpty() {
    return emptyBuilder?.call(context) ??
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No results found'),
        );
  }

  Widget _buildError(Object error) {
    return errorBuilder?.call(context, error) ??
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.red[700]),
          ),
        );
  }

  Widget _buildResults(List<PlacePrediction> predictions) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        return itemBuilder?.call(context, prediction) ??
            _defaultItem(prediction);
      },
    );
  }

  Widget _defaultItem(PlacePrediction prediction) {
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(
        prediction.mainText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        prediction.secondaryText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => handleSelected(prediction),
    );
  }

  // inline suggestions widget

  /// Builds the inline suggestions widget for use in a [Column].
  Widget buildInlineSuggestions() {
    final state = controller.state;
    if (state is PlacesStateIdle) return const SizedBox.shrink();

    return Material(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSuggestionsHeight),
        child: buildSuggestionsList(state),
      ),
    );
  }
}
