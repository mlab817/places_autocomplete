import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

void main() {
  const apiKey = 'test_api_key';

  final validSuggestionsResponse = {
    'suggestions': [
      {
        'placePrediction': {
          'placeId': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
          'place': 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
          'text': {
            'text': 'Amoeba Music, Haight Street, San Francisco, CA, USA',
          },
          'structuredFormat': {
            'mainText': {'text': 'Amoeba Music'},
            'secondaryText': {'text': 'Haight Street, San Francisco, CA, USA'},
          },
          'types': ['establishment'],
        },
      },
    ],
  };

  PlacesAutocompleteController makeController(MockClient client) {
    return PlacesAutocompleteController(
      apiKey: apiKey,
      debounceTime: Duration.zero,
      httpClient: client,
    );
  }

  group('PlacesAutocompleteBuilder', () {
    testWidgets('renders builder output', (tester) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(validSuggestionsResponse), 200);
      });

      final controller = makeController(client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacesAutocompleteBuilder(
              controller: controller,
              onSelected: (_) {},
              builder: (context, state, onSelected) {
                return const Text('Builder rendered');
              },
            ),
          ),
        ),
      );

      expect(find.text('Builder rendered'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('rebuilds when state changes', (tester) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(validSuggestionsResponse), 200);
      });

      final controller = makeController(client);
      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: textController,
                  onChanged: controller.search,
                ),
                PlacesAutocompleteBuilder(
                  controller: controller,
                  onSelected: (_) {},
                  builder: (context, state, onSelected) {
                    return switch (state) {
                      PlacesStateIdle() => const Text('Idle'),
                      PlacesStateLoading() => const Text('Loading'),
                      PlacesStateEmpty() => const Text('Empty'),
                      PlacesStateError() => const Text('Error'),
                      PlacesStateResults(predictions: final p) => Text(
                          '${p.length} results',
                        ),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Idle'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Amoeba');
      await tester.pump();

      expect(find.text('1 results'), findsOneWidget);
      controller.dispose();
      textController.dispose();
    });

    testWidgets('shows idle state initially', (tester) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(validSuggestionsResponse), 200);
      });

      final controller = makeController(client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacesAutocompleteBuilder(
              controller: controller,
              onSelected: (_) {},
              builder: (context, state, onSelected) {
                return switch (state) {
                  PlacesStateIdle() => const Text('Idle'),
                  _ => const Text('Not idle'),
                };
              },
            ),
          ),
        ),
      );

      expect(find.text('Idle'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('calls onSelected and resets controller on selection', (
      tester,
    ) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(validSuggestionsResponse), 200);
      });

      final controller = makeController(client);
      PlacePrediction? received;

      final textController = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: textController,
                  onChanged: controller.search,
                ),
                PlacesAutocompleteBuilder(
                  controller: controller,
                  onSelected: (p) => received = p,
                  builder: (context, state, onSelected) {
                    return switch (state) {
                      PlacesStateResults(predictions: final predictions) =>
                        Column(
                          children: predictions
                              .map(
                                (p) => TextButton(
                                  onPressed: () => onSelected(p),
                                  child: Text(p.mainText),
                                ),
                              )
                              .toList(),
                        ),
                      _ => const Text('no results'),
                    };
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Amoeba');
      await tester.pump();

      expect(find.text('Amoeba Music'), findsOneWidget);

      await tester.tap(find.text('Amoeba Music'));
      await tester.pump();

      expect(received?.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
      expect(controller.state, isA<PlacesStateIdle>());
      controller.dispose();
      textController.dispose();
    });

    testWidgets('disposes without errors', (tester) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(validSuggestionsResponse), 200);
      });

      final controller = makeController(client);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlacesAutocompleteBuilder(
              controller: controller,
              onSelected: (_) {},
              builder: (context, state, onSelected) => const SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      controller.dispose();
    });
  });
}
