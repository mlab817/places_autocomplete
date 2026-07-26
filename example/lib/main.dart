import 'package:flutter/material.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

/// Pass your key at build/run time:
///   flutter run --dart-define=GOOGLE_PLACES_API_KEY=your_key_here
/// Leave it empty to be prompted for a key at app start instead.
const _apiKeyFromEnv = String.fromEnvironment('GOOGLE_PLACES_API_KEY');

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'places_autocomplete example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: _apiKeyFromEnv.isNotEmpty
          ? PlacesDemoPage(apiKey: _apiKeyFromEnv)
          : const ApiKeyPromptPage(),
    );
  }
}

/// Shown when no --dart-define API key was supplied, so the example is
/// still runnable without editing source.
class ApiKeyPromptPage extends StatefulWidget {
  const ApiKeyPromptPage({super.key});

  @override
  State<ApiKeyPromptPage> createState() => _ApiKeyPromptPageState();
}

class _ApiKeyPromptPageState extends State<ApiKeyPromptPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PlacesDemoPage(apiKey: key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('places_autocomplete')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter a Google Places API (New) key to try the demo. '
                  'It is only kept in memory for this run.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'API key',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _continue(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _continue,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlacesDemoPage extends StatefulWidget {
  const PlacesDemoPage({super.key, required this.apiKey});
  final String apiKey;

  @override
  State<PlacesDemoPage> createState() => _PlacesDemoPageState();
}

class _PlacesDemoPageState extends State<PlacesDemoPage> {
  late final PlacesAutocompleteController _controller;

  PlacePrediction? _selected;
  PlaceDetails? _details;
  bool _loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = PlacesAutocompleteController(
      apiKey: widget.apiKey,
      // Bias results toward Manila purely as a demo default — remove or
      // change this for your own use case.
      locationBias: PlacesLocationBias.circle(
        latitude: 14.5995,
        longitude: 120.9842,
        radius: 20000,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSelected(PlacePrediction prediction) async {
    setState(() {
      _selected = prediction;
      _details = null;
      _loadingDetails = true;
    });

    try {
      final details = await _controller.fetchDetails(prediction.placeId);
      if (!mounted) return;
      setState(() => _details = details);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch details: $e')));
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('places_autocomplete demo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlacesAutocompleteTextField(
                controller: _controller,
                onSelected: _onSelected,
                decoration: const InputDecoration(
                  labelText: 'Search a place',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),
              if (_selected != null)
                _SelectedPredictionCard(prediction: _selected!),
              if (_loadingDetails) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_details != null) ...[
                const SizedBox(height: 16),
                Expanded(child: _PlaceDetailsView(details: _details!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPredictionCard extends StatelessWidget {
  const _SelectedPredictionCard({required this.prediction});
  final PlacePrediction prediction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.place_outlined),
        title: Text(prediction.mainText),
        subtitle: Text(prediction.secondaryText),
      ),
    );
  }
}

class _PlaceDetailsView extends StatelessWidget {
  const _PlaceDetailsView({required this.details});
  final PlaceDetails details;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String?)>[
      ('Formatted address', details.formattedAddress),
      ('Latitude', details.latitude?.toString()),
      ('Longitude', details.longitude?.toString()),
      ('Phone', details.internationalPhoneNumber),
      ('Website', details.websiteUri),
      ('Rating', details.rating?.toString()),
    ].where((r) => r.$2 != null).toList();

    return ListView(
      children: [
        Text('Place details', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(child: Text(value!)),
              ],
            ),
          ),
      ],
    );
  }
}
