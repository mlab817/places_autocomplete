import 'package:flutter_test/flutter_test.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

void main() {
  group('PlacesOrigin', () {
    test('toJson returns correct shape', () {
      const origin = PlacesOrigin(latitude: 14.5995, longitude: 120.9842);

      expect(origin.toJson(), {'latitude': 14.5995, 'longitude': 120.9842});
    });
  });
}
