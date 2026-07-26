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

  Widget buildWidget({
    required PlacesAutocompleteController controller,
    required GlobalKey<FormState> formKey,
    void Function(PlacePrediction)? onSelected,
    String? Function(String? value, PlacePrediction? prediction)? validator,
    AutovalidateMode? autovalidateMode,
    DisplayMode displayMode = DisplayMode.inline,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: Column(
            children: [
              PlacesAutocompleteTextFormField(
                controller: controller,
                onSelected: onSelected ?? (_) {},
                validator: validator,
                autovalidateMode: autovalidateMode,
                displayMode: displayMode,
              ),
              ElevatedButton(
                onPressed: () => formKey.currentState!.validate(),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  group('PlacesAutocompleteTextFormField', () {
    group('rendering', () {
      testWidgets('renders text field', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(controller: controller, formKey: formKey),
        );

        expect(find.byType(TextField), findsOneWidget);
        controller.dispose();
      });
    });

    group('validation', () {
      testWidgets('shows error when validator returns error string', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            formKey: formKey,
            validator: (value, prediction) {
              if (prediction == null) return 'Please select a place';
              return null;
            },
          ),
        );

        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(find.text('Please select a place'), findsOneWidget);
        controller.dispose();
      });

      testWidgets('passes validation when prediction is selected', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            formKey: formKey,
            validator: (value, prediction) {
              if (prediction == null) return 'Please select a place';
              return null;
            },
          ),
        );

        // type and select a prediction
        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();
        await tester.tap(find.text('Amoeba Music'));
        await tester.pump();

        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(find.text('Please select a place'), findsNothing);
        controller.dispose();
      });

      testWidgets('passes loose validation with typed text', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            formKey: formKey,
            validator: (value, prediction) {
              if (prediction != null) return null;
              if (value != null && value.isNotEmpty) return null;
              return 'Required';
            },
          ),
        );

        // just type, don't select
        await tester.enterText(find.byType(TextField), 'Camiling, Tarlac');
        await tester.pump();

        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(find.text('Required'), findsNothing);
        controller.dispose();
      });

      testWidgets('clears prediction when user types after selection', (
        tester,
      ) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            formKey: formKey,
            validator: (value, prediction) {
              if (prediction == null) return 'Please select a place';
              return null;
            },
          ),
        );

        // select a prediction
        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();
        await tester.tap(find.text('Amoeba Music'));
        await tester.pump();

        // type again — should clear prediction
        await tester.enterText(find.byType(TextField), 'something else');
        await tester.pump();

        await tester.tap(find.text('Submit'));
        await tester.pump();

        // prediction was cleared so validation should fail
        expect(find.text('Please select a place'), findsOneWidget);
        controller.dispose();
      });

      testWidgets('autovalidates on user interaction', (tester) async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client);
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildWidget(
            controller: controller,
            formKey: formKey,
            validator: (value, prediction) {
              if (prediction == null) return 'Please select a place';
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        );

        // type without selecting
        await tester.enterText(find.byType(TextField), 'Amoeba');
        await tester.pump();

        // error should show automatically without pressing submit
        expect(find.text('Please select a place'), findsOneWidget);
        controller.dispose();
      });
    });
  });
}
