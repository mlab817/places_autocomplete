import 'package:flutter_test/flutter_test.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

void main() {
  group('PlacePrediction', () {
    final validJson = {
      'placePrediction': {
        'placeId': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
        'place': 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
        'text': {
          'text': 'Amoeba Music, Haight Street, San Francisco, CA, USA',
          'matches': [
            {'endOffset': 6},
          ],
        },
        'structuredFormat': {
          'mainText': {
            'text': 'Amoeba Music',
            'matches': [
              {'endOffset': 6},
            ],
          },
          'secondaryText': {'text': 'Haight Street, San Francisco, CA, USA'},
        },
        'types': ['establishment', 'point_of_interest'],
        'distanceMeters': 3012,
      },
    };

    group('fromJson', () {
      test('parses placeId correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(prediction.placeId, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
      });

      test('parses name correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(prediction.name, 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko');
      });

      test('parses description correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(
          prediction.description,
          'Amoeba Music, Haight Street, San Francisco, CA, USA',
        );
      });

      test('parses mainText correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(prediction.mainText, 'Amoeba Music');
      });

      test('parses secondaryText correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(
          prediction.secondaryText,
          'Haight Street, San Francisco, CA, USA',
        );
      });

      test('parses types correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(prediction.types, ['establishment', 'point_of_interest']);
      });

      test('parses distanceMeters correctly', () {
        final prediction = PlacePrediction.fromJson(validJson);
        expect(prediction.distanceMeters, 3012);
      });

      test('distanceMeters is null when not provided', () {
        final jsonWithoutDistance = {
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
          }..remove('distanceMeters'),
        };
        final prediction = PlacePrediction.fromJson(jsonWithoutDistance);
        expect(prediction.distanceMeters, isNull);
      });

      test('types defaults to empty list when not provided', () {
        final jsonWithoutTypes = {
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
          }..remove('types'),
        };
        final prediction = PlacePrediction.fromJson(jsonWithoutTypes);
        expect(prediction.types, isEmpty);
      });

      test('mainText defaults to empty string when not provided', () {
        final jsonWithoutStructuredFormat = {
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
          }..remove('structuredFormat'),
        };
        final prediction = PlacePrediction.fromJson(
          jsonWithoutStructuredFormat,
        );
        expect(prediction.mainText, '');
      });

      test('secondaryText defaults to empty string when not provided', () {
        final jsonWithoutStructuredFormat = {
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
          }..remove('structuredFormat'),
        };
        final prediction = PlacePrediction.fromJson(
          jsonWithoutStructuredFormat,
        );
        expect(prediction.secondaryText, '');
      });
    });

    group('equality', () {
      test('two predictions with same placeId are equal', () {
        final a = PlacePrediction.fromJson(validJson);
        final b = PlacePrediction.fromJson(validJson);
        expect(a, equals(b));
      });

      test('two predictions with different placeId are not equal', () {
        final a = PlacePrediction.fromJson(validJson);
        final b = PlacePrediction.fromJson({
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
            'placeId': 'different_place_id',
          },
        });
        expect(a, isNot(equals(b)));
      });

      test('hashCode is equal for same placeId', () {
        final a = PlacePrediction.fromJson(validJson);
        final b = PlacePrediction.fromJson(validJson);
        expect(a.hashCode, equals(b.hashCode));
      });

      test('hashCode is different for different placeId', () {
        final a = PlacePrediction.fromJson(validJson);
        final b = PlacePrediction.fromJson({
          'placePrediction': {
            ...validJson['placePrediction']! as Map<String, dynamic>,
            'placeId': 'different_place_id',
          },
        });
        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });
}
