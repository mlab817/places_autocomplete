import 'package:flutter_test/flutter_test.dart';
import 'package:places_autocomplete/places_autocomplete.dart';

void main() {
  group('PlaceDetails', () {
    final validJson = {
      'id': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
      'name': 'places/ChIJ5YQQf1GHhYARPKG7WLIaOko',
      'formattedAddress': 'Haight Street, San Francisco, CA, USA',
      'shortFormattedAddress': 'Haight St, San Francisco',
      'location': {'latitude': 37.7937, 'longitude': -122.3965},
      'viewport': {
        'low': {'latitude': 37.7751, 'longitude': -122.4219},
        'high': {'latitude': 37.7955, 'longitude': -122.3937},
      },
      'displayName': {'text': 'Amoeba Music', 'languageCode': 'en'},
      'types': ['establishment', 'point_of_interest'],
      'rating': 4.5,
      'userRatingCount': 1000,
      'websiteUri': 'https://amoeba.com',
      'nationalPhoneNumber': '(415) 831-1200',
      'internationalPhoneNumber': '+1 415-831-1200',
      'googleMapsUri': 'https://maps.google.com/?cid=123',
      'regularOpeningHours': {
        'openNow': true,
        'weekdayDescriptions': [
          'Monday: 11:00 AM – 8:00 PM',
          'Tuesday: 11:00 AM – 8:00 PM',
        ],
      },
      'delivery': true,
      'dineIn': false,
      'takeout': true,
      'accessibilityOptions': {
        'wheelchairAccessibleEntrance': true,
        'wheelchairAccessibleParking': false,
        'wheelchairAccessibleRestroom': true,
        'wheelchairAccessibleSeating': false,
      },
      'parkingOptions': {
        'freeParkingLot': false,
        'paidParkingLot': true,
        'freeStreetParking': true,
      },
      'paymentOptions': {
        'acceptsCreditCards': true,
        'acceptsCashOnly': false,
        'acceptsDebitCards': true,
        'acceptsNfc': true,
      },
      'photos': [
        {'name': 'places/ChIJ.../photos/AUc7tXqZx'},
        {'name': 'places/ChIJ.../photos/AUc7tXqZy'},
      ],
      'editorialSummary': {
        'text': 'A legendary music store.',
        'languageCode': 'en',
      },
      'plusCode': {
        'globalCode': '849VCWC8+R9',
        'compoundCode': 'CWC8+R9 San Francisco',
      },
      'addressComponents': [
        {
          'longText': '123',
          'shortText': '123',
          'types': ['street_number'],
        },
        {
          'longText': 'Haight Street',
          'shortText': 'Haight St',
          'types': ['route'],
        },
        {
          'longText': 'San Francisco',
          'shortText': 'SF',
          'types': ['locality'],
        },
        {
          'longText': 'California',
          'shortText': 'CA',
          'types': ['administrative_area_level_1'],
        },
        {
          'longText': 'United States',
          'shortText': 'US',
          'types': ['country'],
        },
        {
          'longText': '94117',
          'shortText': '94117',
          'types': ['postal_code'],
        },
      ],
    };

    group('fromJson', () {
      test('parses id correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.id, 'ChIJ5YQQf1GHhYARPKG7WLIaOko');
      });

      test('parses formattedAddress correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(
          details.formattedAddress,
          'Haight Street, San Francisco, CA, USA',
        );
      });

      test('parses latitude correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.latitude, 37.7937);
      });

      test('parses longitude correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.longitude, -122.3965);
      });

      test('parses viewport correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.viewportSouthLat, 37.7751);
        expect(details.viewportSouthLng, -122.4219);
        expect(details.viewportNorthLat, 37.7955);
        expect(details.viewportNorthLng, -122.3937);
      });

      test('parses displayName correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.displayName, 'Amoeba Music');
        expect(details.displayNameLanguageCode, 'en');
      });

      test('parses types correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.types, ['establishment', 'point_of_interest']);
      });

      test('parses rating correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.rating, 4.5);
      });

      test('parses userRatingCount correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.userRatingCount, 1000);
      });

      test('parses websiteUri correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.websiteUri, 'https://amoeba.com');
      });

      test('parses phone numbers correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.nationalPhoneNumber, '(415) 831-1200');
        expect(details.internationalPhoneNumber, '+1 415-831-1200');
      });

      test('parses opening hours correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.regularOpeningHoursOpenNow, true);
        expect(details.regularOpeningHoursWeekdayDescriptions, [
          'Monday: 11:00 AM – 8:00 PM',
          'Tuesday: 11:00 AM – 8:00 PM',
        ]);
      });

      test('parses atmosphere fields correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.delivery, true);
        expect(details.dineIn, false);
        expect(details.takeout, true);
      });

      test('parses accessibility options correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.wheelchairAccessibleEntrance, true);
        expect(details.wheelchairAccessibleParking, false);
        expect(details.wheelchairAccessibleRestroom, true);
        expect(details.wheelchairAccessibleSeating, false);
      });

      test('parses parking options correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.freeParkingLot, false);
        expect(details.paidParkingLot, true);
        expect(details.freeStreetParking, true);
      });

      test('parses payment options correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.acceptsCreditCards, true);
        expect(details.acceptsCashOnly, false);
        expect(details.acceptsDebitCards, true);
        expect(details.acceptsNfc, true);
      });

      test('parses photo references correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.photoReferences, [
          'places/ChIJ.../photos/AUc7tXqZx',
          'places/ChIJ.../photos/AUc7tXqZy',
        ]);
      });

      test('parses editorial summary correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.editorialSummary, 'A legendary music store.');
        expect(details.editorialSummaryLanguageCode, 'en');
      });

      test('parses plus code correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.plusCodeGlobal, '849VCWC8+R9');
        expect(details.plusCodeCompound, 'CWC8+R9 San Francisco');
      });

      test('parses address components correctly', () {
        final details = PlaceDetails.fromJson(validJson);
        expect(details.streetNumber, '123');
        expect(details.route, 'Haight Street');
        expect(details.locality, 'San Francisco');
        expect(details.administrativeAreaLevel1, 'California');
        expect(details.country, 'United States');
        expect(details.countryCode, 'US');
        expect(details.postalCode, '94117');
      });

      test('nullable fields are null when not provided', () {
        final details = PlaceDetails.fromJson(const {
          'id': 'ChIJ5YQQf1GHhYARPKG7WLIaOko',
        });
        expect(details.formattedAddress, isNull);
        expect(details.latitude, isNull);
        expect(details.longitude, isNull);
        expect(details.rating, isNull);
        expect(details.websiteUri, isNull);
        expect(details.photoReferences, isNull);
      });
    });

    group('equality', () {
      test('two details with same id are equal', () {
        final a = PlaceDetails.fromJson(validJson);
        final b = PlaceDetails.fromJson(validJson);
        expect(a, equals(b));
      });

      test('two details with different id are not equal', () {
        final a = PlaceDetails.fromJson(validJson);
        final b = PlaceDetails.fromJson({...validJson, 'id': 'different_id'});
        expect(a, isNot(equals(b)));
      });

      test('hashCode is equal for same id', () {
        final a = PlaceDetails.fromJson(validJson);
        final b = PlaceDetails.fromJson(validJson);
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
