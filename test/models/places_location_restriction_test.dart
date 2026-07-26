import 'package:flutter_test/flutter_test.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

void main() {
  group('PlacesLocationRestriction', () {
    group('circle', () {
      test('toJson returns correct shape', () {
        final restriction = PlacesLocationRestriction.circle(
          latitude: 14.5995,
          longitude: 120.9842,
          radius: 5000,
        );

        expect(restriction.toJson(), {
          'circle': {
            'center': {'latitude': 14.5995, 'longitude': 120.9842},
            'radius': 5000.0,
          },
        });
      });

      test('throws assertion error when radius is 0', () {
        expect(
          () => PlacesLocationRestriction.circle(
            latitude: 14.5995,
            longitude: 120.9842,
            radius: 0,
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('accepts max radius of 50000', () {
        expect(
          () => PlacesLocationRestriction.circle(
            latitude: 14.5995,
            longitude: 120.9842,
            radius: 50000,
          ),
          returnsNormally,
        );
      });

      test('throws assertion error when radius exceeds 50000', () {
        expect(
          () => PlacesLocationRestriction.circle(
            latitude: 14.5995,
            longitude: 120.9842,
            radius: 50001,
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('rectangle', () {
      test('toJson returns correct shape', () {
        final restriction = PlacesLocationRestriction.rectangle(
          lowLatitude: 14.4081,
          lowLongitude: 120.8976,
          highLatitude: 14.7579,
          highLongitude: 121.1234,
        );

        expect(restriction.toJson(), {
          'rectangle': {
            'low': {'latitude': 14.4081, 'longitude': 120.8976},
            'high': {'latitude': 14.7579, 'longitude': 121.1234},
          },
        });
      });
    });
  });
}
