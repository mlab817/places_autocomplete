import 'dart:convert';

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

  final validDetailsResponse = {
    'id': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
    'name': 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
    'formattedAddress': 'Haight Street, San Francisco, CA, USA',
    'location': {'latitude': 37.7937, 'longitude': -122.3965},
    'displayName': {'text': 'Amoeba Music', 'languageCode': 'en'},
  };

  // helper to create controller with mock http client
  PlacesAutocompleteController makeController({
    required MockClient client,
    Duration debounceTime = Duration.zero,
    Duration cacheTTL = const Duration(minutes: 5),
    List<String>? countries,
    int maxResults = 5,
    PlacesLocationBias? locationBias,
    PlacesLocationRestriction? locationRestriction,
  }) {
    return PlacesAutocompleteController(
      apiKey: apiKey,
      debounceTime: debounceTime,
      cacheTTL: cacheTTL,
      countries: countries,
      maxResults: maxResults,
      locationBias: locationBias,
      locationRestriction: locationRestriction,
      httpClient: client,
    );
  }

  group('PlacesAutocompleteController', () {
    group('initial state', () {
      test('starts with PlacesStateIdle', () {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client);
        expect(controller.state, isA<PlacesStateIdle>());
        controller.dispose();
      });
    });

    group('search', () {
      test('sets PlacesStateIdle on empty query', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client)..search('');
        expect(controller.state, isA<PlacesStateIdle>());
        controller.dispose();
      });

      test('sets PlacesStateIdle on whitespace query', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client)..search('   ');
        expect(controller.state, isA<PlacesStateIdle>());
        controller.dispose();
      });

      test(
        'sets PlacesStateLoading then PlacesStateResults on success',
        () async {
          final client = MockClient((request) async {
            return http.Response(jsonEncode(validSuggestionsResponse), 200);
          });

          final controller = makeController(client: client);
          final states = <PlacesAutocompleteState>[];
          controller.stateNotifier.addListener(() {
            states.add(controller.state);
          });

          controller.search('Amoeba');
          await Future<void>.delayed(Duration.zero);

          expect(states, [
            isA<PlacesStateLoading>(),
            isA<PlacesStateResults>(),
          ]);

          final results = states.last as PlacesStateResults;
          expect(results.predictions.length, 1);
          expect(
            results.predictions.first.placeId,
            'ChIJ5YQQf1GHhYARPKG7WLIaOko',
          );

          controller.dispose();
        },
      );

      test('sets PlacesStateEmpty when no results', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'suggestions': <dynamic>[]}),
            200,
          );
        });

        final controller = makeController(client: client);
        final states = <PlacesAutocompleteState>[];
        controller.stateNotifier.addListener(() {
          states.add(controller.state);
        });

        controller.search('xyznotfound');
        await Future<void>.delayed(Duration.zero);

        expect(states.last, isA<PlacesStateEmpty>());
        controller.dispose();
      });

      test('sets PlacesStateError on service exception', () async {
        final client = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final controller = makeController(client: client);
        final states = <PlacesAutocompleteState>[];
        controller.stateNotifier.addListener(() {
          states.add(controller.state);
        });

        controller.search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        expect(states.last, isA<PlacesStateError>());
        final error = states.last as PlacesStateError;
        expect(error.error, isA<PlacesServiceException>());
        controller.dispose();
      });

      test('debounces multiple rapid calls', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(
          client: client,
          debounceTime: const Duration(milliseconds: 300),
        )
          ..search('A')
          ..search('Am')
          ..search('Amo')
          ..search('Amoe')
          ..search('Amoeb')
          ..search('Amoeba');

        await Future<void>.delayed(const Duration(milliseconds: 400));

        // only one API call should have been made
        expect(callCount, 1);
        controller.dispose();
      });

      test('cancels previous debounce on new search', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(
          client: client,
          debounceTime: const Duration(milliseconds: 300),
        )..search('Amoeba');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // new search before debounce fires
        controller.search('Berkeley');
        await Future<void>.delayed(const Duration(milliseconds: 400));

        // only one call — for 'Berkeley'
        expect(callCount, 1);
        controller.dispose();
      });
    });

    group('cache', () {
      test('returns cached results within TTL', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client)..search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        controller.search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        // only one API call — second was cached
        expect(callCount, 1);
        expect(controller.state, isA<PlacesStateResults>());
        controller.dispose();
      });

      test('hits API again after TTL expires', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(
          client: client,
          cacheTTL: const Duration(milliseconds: 100),
        )..search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        // wait for cache to expire
        await Future<void>.delayed(const Duration(milliseconds: 200));

        controller.search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        // two API calls — cache expired
        expect(callCount, 2);
        controller.dispose();
      });

      test('clearCache forces fresh API call', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client)..search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        controller
          ..clearCache()
          ..search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        // two API calls — cache was cleared
        expect(callCount, 2);
        controller.dispose();
      });

      test('different queries are cached separately', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client)..search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        controller.search('Berkeley');
        await Future<void>.delayed(Duration.zero);

        controller.search('Amoeba');
        await Future<void>.delayed(Duration.zero);

        // two API calls — Amoeba was cached, Berkeley was new
        expect(callCount, 2);
        controller.dispose();
      });
    });

    group('fetchDetails', () {
      test('returns PlaceDetails on success', () async {
        final client = MockClient((request) async {
          if (request.url.path.contains('places:autocomplete')) {
            return http.Response(jsonEncode(validSuggestionsResponse), 200);
          }
          return http.Response(jsonEncode(validDetailsResponse), 200);
        });

        final controller = makeController(client: client);
        final details = await controller.fetchDetails(
          'ChIJ5YQQf1GHhYARPKG7WLIaOko',
        );

        expect(details.id, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
        expect(
          details.formattedAddress,
          'Haight Street, San Francisco, CA, USA',
        );
        expect(details.latitude, 37.7937);
        expect(details.longitude, -122.3965);
        controller.dispose();
      });

      test('resets session token after fetchDetails', () async {
        final sessionTokens = <String>[];

        final client = MockClient((request) async {
          // Autocomplete sends the session token in the JSON body; fetchDetails
          // is a GET request and sends it via the X-Goog-Session-Token header.
          if (request.body.isNotEmpty) {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body.containsKey('sessionToken')) {
              sessionTokens.add(body['sessionToken'] as String);
            }
          } else if (request.headers['X-Goog-Session-Token'] != null) {
            sessionTokens.add(request.headers['X-Goog-Session-Token']!);
          }
          if (request.url.path.contains('places:autocomplete')) {
            return http.Response(jsonEncode(validSuggestionsResponse), 200);
          }
          return http.Response(jsonEncode(validDetailsResponse), 200);
        });

        // first search
        final controller = makeController(client: client)..search('Amoeba');
        await Future<void>.delayed(Duration.zero);
        final firstToken = sessionTokens.last;

        // fetch details — should reset token
        await controller.fetchDetails('ChIJ5YQQf1GHhYARPKG7WLIaOko');

        // second search — should use new token
        controller
          ..clearCache()
          ..search('Amoeba');
        await Future<void>.delayed(Duration.zero);
        final secondToken = sessionTokens.last;

        expect(firstToken, isNot(equals(secondToken)));
        controller.dispose();
      });

      test('throws PlacesServiceException on failure', () async {
        final client = MockClient((request) async {
          return http.Response('Not found', 404);
        });

        final controller = makeController(client: client);

        expect(
          () => controller.fetchDetails('invalid_place_id'),
          throwsA(isA<PlacesServiceException>()),
        );
        controller.dispose();
      });
    });

    group('assertions', () {
      test('throws assertion error when maxResults is less than 1', () {
        expect(
          () => PlacesAutocompleteController(apiKey: apiKey, maxResults: 0),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws assertion error when maxResults exceeds 5', () {
        expect(
          () => PlacesAutocompleteController(apiKey: apiKey, maxResults: 6),
          throwsA(isA<AssertionError>()),
        );
      });

      test(
        'throws assertion error when both locationBias and '
        'locationRestriction are provided',
        () {
          expect(
            () => PlacesAutocompleteController(
              apiKey: apiKey,
              locationBias: PlacesLocationBias.circle(
                latitude: 14.5995,
                longitude: 120.9842,
                radius: 5000,
              ),
              locationRestriction: PlacesLocationRestriction.circle(
                latitude: 14.5995,
                longitude: 120.9842,
                radius: 5000,
              ),
            ),
            throwsA(isA<AssertionError>()),
          );
        },
      );
    });

    group('dispose', () {
      test('disposes without errors', () {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final controller = makeController(client: client);
        expect(controller.dispose, returnsNormally);
      });

      test('cancels pending debounce on dispose', () async {
        var callCount = 0;

        final client = MockClient((request) async {
          callCount++;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        makeController(
          client: client,
          debounceTime: const Duration(milliseconds: 300),
        )
          ..search('Amoeba')
          ..dispose();

        // wait longer than debounce
        await Future<void>.delayed(const Duration(milliseconds: 400));

        // no API call should have been made
        expect(callCount, 0);
      });
    });
  });
}
