import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:places_autocomplete/places_autocomplete.dart';
import 'package:places_autocomplete/src/service/places_autocomplete_service.dart';

void main() {
  const apiKey = 'test_api_key';
  const sessionToken = 'test_session_token';

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
          'types': ['establishment', 'point_of_interest'],
          'distanceMeters': 3012,
        },
      },
      {
        'placePrediction': {
          'placeId': 'ChIJr7uwwy58hYARBY',
          'place': 'places/ChIJr7uwwy58hYARBY',
          'text': {'text': 'Amoeba Music, Telegraph Avenue, Berkeley, CA, USA'},
          'structuredFormat': {
            'mainText': {'text': 'Amoeba Music'},
            'secondaryText': {'text': 'Telegraph Avenue, Berkeley, CA, USA'},
          },
          'types': ['establishment', 'point_of_interest'],
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

  PlacesAutocompleteService makeService(MockClient client) {
    return PlacesAutocompleteService(apiKey: apiKey, httpClient: client);
  }

  group('PlacesAutocompleteService', () {
    group('fetchSuggestions', () {
      test('returns predictions on 200', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        final predictions = await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        expect(predictions.length, 2);
        expect(predictions.first.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
        expect(predictions.first.mainText, 'Amoeba Music');
      });

      test('respects maxResults', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        final predictions = await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
          maxResults: 1,
        );

        expect(predictions.length, 1);
      });

      test('returns empty list when no suggestions', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'suggestions': <dynamic>[]}),
            200,
          );
        });

        final service = makeService(client);
        final predictions = await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        expect(predictions, isEmpty);
      });

      test('returns empty list when suggestions key is missing', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(<String, dynamic>{}), 200);
        });

        final service = makeService(client);
        final predictions = await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        expect(predictions, isEmpty);
      });

      test('filters out queryPredictions', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'suggestions': [
                {
                  'placePrediction': {
                    'placeId': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
                    'place': 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
                    'text': {'text': 'Amoeba Music'},
                    'structuredFormat': {
                      'mainText': {'text': 'Amoeba Music'},
                      'secondaryText': {'text': 'Haight Street'},
                    },
                    'types': ['establishment'],
                  },
                },
                {
                  'queryPrediction': {
                    'text': {'text': 'Amoeba Music stores'},
                  },
                },
              ],
            }),
            200,
          );
        });

        final service = makeService(client);
        final predictions = await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        expect(predictions.length, 1);
        expect(predictions.first.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
      });

      test('throws PlacesServiceException on non-200', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'error': {'message': 'API key invalid'},
            }),
            400,
          );
        });

        final service = makeService(client);

        expect(
          () => service.fetchSuggestions(
            query: 'Amoeba',
            sessionToken: sessionToken,
          ),
          throwsA(isA<PlacesServiceException>()),
        );
      });

      test('throws PlacesServiceException on 500', () async {
        final client = MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        });

        final service = makeService(client);

        expect(
          () => service.fetchSuggestions(
            query: 'Amoeba',
            sessionToken: sessionToken,
          ),
          throwsA(isA<PlacesServiceException>()),
        );
      });

      test('sends correct headers', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        expect(capturedRequest?.headers['X-Goog-Api-Key'], apiKey);
        expect(capturedRequest?.headers['Content-Type'], 'application/json');
        expect(capturedRequest?.headers['X-Goog-FieldMask'], isNotNull);
      });

      test('sends correct request body', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
          countries: ['us', 'ph'],
        );

        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body['input'], 'Amoeba');
        expect(body['sessionToken'], sessionToken);
        expect(body['includedRegionCodes'], ['us', 'ph']);
      });

      test('does not send countries when null', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
        );

        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body.containsKey('includedRegionCodes'), false);
      });

      test('sends locationBias when provided', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
          locationBias: PlacesLocationBias.circle(
            latitude: 14.5995,
            longitude: 120.9842,
            radius: 5000,
          ),
        );

        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body.containsKey('locationBias'), true);
        expect(body.containsKey('locationRestriction'), false);
      });

      test('sends locationRestriction when provided', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validSuggestionsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchSuggestions(
          query: 'Amoeba',
          sessionToken: sessionToken,
          locationRestriction: PlacesLocationRestriction.circle(
            latitude: 14.5995,
            longitude: 120.9842,
            radius: 5000,
          ),
        );

        final body = jsonDecode(capturedRequest!.body) as Map<String, dynamic>;
        expect(body.containsKey('locationRestriction'), true);
        expect(body.containsKey('locationBias'), false);
      });

      test(
        'throws assertion error when both locationBias and '
        'locationRestriction are provided',
        () {
          final client = MockClient((request) async {
            return http.Response(jsonEncode(<String, dynamic>{}), 200);
          });

          final service = makeService(client);

          expect(
            () => service.fetchSuggestions(
              query: 'Amoeba',
              sessionToken: sessionToken,
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

    group('fetchDetails', () {
      test('returns PlaceDetails on 200', () async {
        final client = MockClient((request) async {
          return http.Response(jsonEncode(validDetailsResponse), 200);
        });

        final service = makeService(client);
        final details = await service.fetchDetails(
          placeId: 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
          sessionToken: sessionToken,
        );

        expect(details.id, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
        expect(
          details.formattedAddress,
          'Haight Street, San Francisco, CA, USA',
        );
        expect(details.latitude, 37.7937);
        expect(details.longitude, -122.3965);
        expect(details.displayName, 'Amoeba Music');
      });

      test('throws PlacesServiceException on non-200', () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'error': {'message': 'Not found'},
            }),
            404,
          );
        });

        final service = makeService(client);

        expect(
          () => service.fetchDetails(
            placeId: 'invalid_place_id',
            sessionToken: sessionToken,
          ),
          throwsA(isA<PlacesServiceException>()),
        );
      });

      test('sends correct headers', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validDetailsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchDetails(
          placeId: 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
          sessionToken: sessionToken,
        );

        expect(capturedRequest?.headers['X-Goog-Api-Key'], apiKey);
        expect(capturedRequest?.headers['X-Goog-FieldMask'], '*');
        expect(capturedRequest?.headers['X-Goog-Session-Token'], sessionToken);
      });

      test('sends request to correct url', () async {
        http.Request? capturedRequest;

        final client = MockClient((request) async {
          capturedRequest = request;
          return http.Response(jsonEncode(validDetailsResponse), 200);
        });

        final service = makeService(client);
        await service.fetchDetails(
          placeId: 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
          sessionToken: sessionToken,
        );

        expect(
          capturedRequest?.url.toString(),
          'https://places.googleapis.com/v1/places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
        );
      });
    });
  });
}
