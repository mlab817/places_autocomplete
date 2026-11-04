import 'dart:convert';

import 'package:flutter/gestures.dart';
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

  Widget buildWidget({
    required PlacesAutocompleteController controller,
    void Function(PlacePrediction)? onSelected,
    DisplayMode displayMode = DisplayMode.overlay,
    InputDecoration? decoration,
    Widget Function(BuildContext, PlacePrediction)? itemBuilder,
    Widget Function(BuildContext)? loadingBuilder,
    Widget Function(BuildContext)? emptyBuilder,
    Widget Function(BuildContext, Object)? errorBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PlacesAutocompleteTextField(
          controller: controller,
          onSelected: onSelected ?? (_) {},
          displayMode: displayMode,
          decoration: decoration,
          itemBuilder: itemBuilder,
          loadingBuilder: loadingBuilder,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
        ),
      ),
    );
  }

  group('PlacesAutocompleteTextField', () {
    group('rendering', () {
      testWidgets('renders text field', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.byType(TextField), findsOneWidget);
        controller.dispose();
      });

      testWidgets('renders with custom decoration', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Search here...'),
          ),
        );

        expect(find.text('Search here...'), findsOneWidget);
        controller.dispose();
      });

      testWidgets('renders default hint text when no decoration provided', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(buildWidget(controller: controller));

        expect(find.text('Search places...'), findsOneWidget);
        controller.dispose();
      });
    });

    group('search', () {
      testWidgets('triggers search on text input', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(buildWidget(controller: controller));
        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(controller.state, isA<PlacesStateResults>());
        controller.dispose();
      });

      testWidgets('shows loading state while fetching', (tester) async {
        final client = MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        var loadingBuilderCalled = false;

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            displayMode: DisplayMode.inline,
            loadingBuilder: (context) {
              loadingBuilderCalled = true;
              return const Text('Loading...');
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(loadingBuilderCalled, true);

        // Let the mock client's delayed response resolve before the test
        // ends, otherwise its pending Timer trips the framework's
        // "timer still pending after dispose" check.
        await tester.pump(const Duration(milliseconds: 150));
        controller.dispose();
      });

      testWidgets('shows empty state when no results', (tester) async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'suggestions': <dynamic>[]}),
            200,
          );
        });

        final controller = makeController(client);
        var emptyBuilderCalled = false;

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            displayMode: DisplayMode.inline,
            emptyBuilder: (context) {
              emptyBuilderCalled = true;
              return const Text('No results');
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'xyznotfound');
        await tester.pump();

        expect(emptyBuilderCalled, true);
        controller.dispose();
      });

      testWidgets('shows error state on failure', (tester) async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final controller = makeController(client);
        var errorBuilderCalled = false;

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            displayMode: DisplayMode.inline,
            errorBuilder: (context, error) {
              errorBuilderCalled = true;
              return const Text('Error');
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(errorBuilderCalled, true);
        controller.dispose();
      });
    });

    group('inline mode', () {
      testWidgets('shows suggestions below text field in inline mode', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(
          buildWidget(controller: controller, displayMode: DisplayMode.inline),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(find.text('Amoeba Music'), findsOneWidget);
        expect(
          find.text('Haight Street, San Francisco, CA, USA'),
          findsOneWidget,
        );
        controller.dispose();
      });

      testWidgets('uses custom itemBuilder when provided', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            displayMode: DisplayMode.inline,
            itemBuilder: (context, prediction) {
              return Text('Custom: ${prediction.mainText}');
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(find.text('Custom: Amoeba Music'), findsOneWidget);
        controller.dispose();
      });
    });

    group('selection', () {
      testWidgets(
        'calls onSelected when overlay suggestion is clicked with a mouse',
        (tester) async {
          final client = MockClient((request) async {
            return http.Response(jsonEncode(validSuggestionsResponse), 200);
          });

          final controller = makeController(client);
          PlacePrediction? selectedPrediction;

          await tester.pumpWidget(
            buildWidget(
              controller: controller,
              onSelected: (prediction) => selectedPrediction = prediction,
            ),
          );

          await tester.enterText(find.byType(TextField), 'Amoeba');
          await tester.pump();

          // A mouse pointer-down outside the field's tap region unfocuses it,
          // which must not tear down the overlay before the tap lands.
          final gesture = await tester.startGesture(
            tester.getCenter(find.text('Amoeba Music')),
            kind: PointerDeviceKind.mouse,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await gesture.up();
          await tester.pump();

          expect(selectedPrediction, isNotNull);
          expect(selectedPrediction!.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
          controller.dispose();
        },
      );

      testWidgets('calls onSelected when a custom itemBuilder row is tapped', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        PlacePrediction? selectedPrediction;

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            onSelected: (prediction) => selectedPrediction = prediction,
            itemBuilder: (context, prediction) =>
                ListTile(title: Text('Custom: ${prediction.mainText}')),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        await tester.tap(find.text('Custom: Amoeba Music'));
        await tester.pump();

        expect(selectedPrediction, isNotNull);
        controller.dispose();
      });

      testWidgets('calls onSelected when suggestion is tapped', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        PlacePrediction? selectedPrediction;

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            displayMode: DisplayMode.inline,
            onSelected: (prediction) {
              selectedPrediction = prediction;
            },
          ),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        await tester.tap(find.text('Amoeba Music'));
        await tester.pump();

        expect(selectedPrediction, isNotNull);
        expect(selectedPrediction!.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
        controller.dispose();
      });

      testWidgets(
        'sets text field value to prediction description on selection',
        (tester) async {
          final client = MockClient((request) async {
            return http.Response(jsonEncode(validSuggestionsResponse), 200);
          });

          final controller = makeController(client);

          await tester.pumpWidget(
            buildWidget(
              controller: controller,
              displayMode: DisplayMode.inline,
            ),
          );

          await tester.enterText(find.byType(TextField), 'Amoeba');
          await tester.pump();

          await tester.tap(find.text('Amoeba Music'));
          await tester.pump();

          expect(
            find.text('Amoeba Music, Haight Street, San Francisco, CA, USA'),
            findsOneWidget,
          );
          controller.dispose();
        },
      );

      testWidgets('hides suggestions after selection', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(
          buildWidget(controller: controller, displayMode: DisplayMode.inline),
        );

        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        expect(find.text('Amoeba Music'), findsOneWidget);

        await tester.tap(find.text('Amoeba Music'));
        await tester.pump();

        // suggestions should be gone
        expect(controller.state, isA<PlacesStateIdle>());
        controller.dispose();
      });
    });

    group('dispose', () {
      testWidgets('disposes without errors', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);

        await tester.pumpWidget(buildWidget(controller: controller));
        await tester.pumpWidget(const SizedBox());

        expect(tester.takeException(), isNull);
        controller.dispose();
      });
    });
  });
}
