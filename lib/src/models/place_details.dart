import 'package:flutter/foundation.dart';

/// Detailed information about a place returned from the Google Places API.
///
/// All fields are optional because the available data depends on the API tier
/// and on which fields were requested via the field mask.
@immutable
class PlaceDetails {
  /// Creates a [PlaceDetails] instance.
  const PlaceDetails({
    // IDs
    this.id,
    this.name,

    // Essentials
    this.formattedAddress,
    this.shortFormattedAddress,
    this.adrFormatAddress,
    this.latitude,
    this.longitude,
    this.viewportNorthLat,
    this.viewportNorthLng,
    this.viewportSouthLat,
    this.viewportSouthLng,
    this.plusCodeGlobal,
    this.plusCodeCompound,
    this.postalAddressRegion,
    this.postalAddressPostalCode,
    this.postalAddressCountry,
    this.postalAddressCity,
    this.types,

    // Address Components
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeAreaLevel1,
    this.administrativeAreaLevel2,
    this.country,
    this.countryCode,
    this.postalCode,

    // Pro
    this.displayName,
    this.displayNameLanguageCode,
    this.primaryType,
    this.primaryTypeDisplayName,
    this.businessStatus,
    this.googleMapsUri,
    this.iconBackgroundColor,
    this.iconMaskBaseUri,
    this.timeZoneId,
    this.utcOffsetMinutes,
    this.pureServiceAreaBusiness,
    this.openingDate,

    // Enterprise
    this.nationalPhoneNumber,
    this.internationalPhoneNumber,
    this.websiteUri,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.priceRangeMinPrice,
    this.priceRangeMaxPrice,
    this.priceRangeCurrency,

    // Opening Hours (regular)
    this.regularOpeningHoursOpenNow,
    this.regularOpeningHoursPeriods,
    this.regularOpeningHoursWeekdayDescriptions,

    // Opening Hours (current)
    this.currentOpeningHoursOpenNow,
    this.currentOpeningHoursPeriods,
    this.currentOpeningHoursWeekdayDescriptions,

    // Atmosphere / Enterprise+
    this.allowsDogs,
    this.curbsidePickup,
    this.delivery,
    this.dineIn,
    this.takeout,
    this.reservable,
    this.restroom,
    this.goodForChildren,
    this.goodForGroups,
    this.goodForWatchingSports,
    this.liveMusic,
    this.menuForChildren,
    this.outdoorSeating,
    this.servesBeer,
    this.servesBreakfast,
    this.servesBrunch,
    this.servesCocktails,
    this.servesCoffee,
    this.servesDessert,
    this.servesDinner,
    this.servesLunch,
    this.servesVegetarianFood,
    this.servesWine,

    // Accessibility
    this.wheelchairAccessibleEntrance,
    this.wheelchairAccessibleParking,
    this.wheelchairAccessibleRestroom,
    this.wheelchairAccessibleSeating,

    // Parking
    this.freeParkingLot,
    this.paidParkingLot,
    this.freeStreetParking,
    this.paidStreetParking,
    this.valetParking,
    this.freeGarageParking,
    this.paidGarageParking,

    // Payment
    this.acceptsCashOnly,
    this.acceptsCreditCards,
    this.acceptsDebitCards,
    this.acceptsNfc,

    // Photos
    this.photoReferences,

    // Editorial / AI summaries
    this.editorialSummary,
    this.editorialSummaryLanguageCode,
    this.generativeSummary,
    this.reviewSummary,
    this.neighborhoodSummary,
  });

  /// Deserializes a [PlaceDetails] from a Google Places API JSON response.
  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    // helpers
    String? str(dynamic v) => v as String?;
    bool? boolean(dynamic v) => v as bool?;
    int? integer(dynamic v) => v as int?;
    double? dbl(dynamic v) => v == null ? null : (v as num).toDouble();

    // nested maps
    final location = json['location'] as Map<String, dynamic>?;
    final viewport = json['viewport'] as Map<String, dynamic>?;
    final north = viewport?['high'] as Map<String, dynamic>?;
    final south = viewport?['low'] as Map<String, dynamic>?;
    final plusCode = json['plusCode'] as Map<String, dynamic>?;
    final postalAddress = json['postalAddress'] as Map<String, dynamic>?;
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final primaryTypeDisplayName =
        json['primaryTypeDisplayName'] as Map<String, dynamic>?;
    final editorialSummary = json['editorialSummary'] as Map<String, dynamic>?;
    final priceRange = json['priceRange'] as Map<String, dynamic>?;
    final regularOpeningHours =
        json['regularOpeningHours'] as Map<String, dynamic>?;
    final currentOpeningHours =
        json['currentOpeningHours'] as Map<String, dynamic>?;
    final accessibilityOptions =
        json['accessibilityOptions'] as Map<String, dynamic>?;
    final parkingOptions = json['parkingOptions'] as Map<String, dynamic>?;
    final paymentOptions = json['paymentOptions'] as Map<String, dynamic>?;
    final generativeSummary =
        json['generativeSummary'] as Map<String, dynamic>?;
    final reviewSummary = json['reviewSummary'] as Map<String, dynamic>?;
    final neighborhoodSummary =
        json['neighborhoodSummary'] as Map<String, dynamic>?;

    // address components helper
    final addressComponents = json['addressComponents'] as List<dynamic>? ?? [];

    String? component(String type) {
      final match = addressComponents.cast<Map<String, dynamic>>().firstWhere(
            (c) => (c['types'] as List<dynamic>).contains(type),
            orElse: () => {},
          );
      return match.isEmpty ? null : match['longText'] as String?;
    }

    String? componentShort(String type) {
      final match = addressComponents.cast<Map<String, dynamic>>().firstWhere(
            (c) => (c['types'] as List<dynamic>).contains(type),
            orElse: () => {},
          );
      return match.isEmpty ? null : match['shortText'] as String?;
    }

    return PlaceDetails(
      // IDs
      id: str(json['id']),
      name: str(json['name']),

      // Essentials
      formattedAddress: str(json['formattedAddress']),
      shortFormattedAddress: str(json['shortFormattedAddress']),
      adrFormatAddress: str(json['adrFormatAddress']),
      latitude: dbl(location?['latitude']),
      longitude: dbl(location?['longitude']),
      viewportNorthLat: dbl(north?['latitude']),
      viewportNorthLng: dbl(north?['longitude']),
      viewportSouthLat: dbl(south?['latitude']),
      viewportSouthLng: dbl(south?['longitude']),
      plusCodeGlobal: str(plusCode?['globalCode']),
      plusCodeCompound: str(plusCode?['compoundCode']),
      postalAddressRegion: str(postalAddress?['administrativeArea']),
      postalAddressPostalCode: str(postalAddress?['postalCode']),
      postalAddressCountry: str(postalAddress?['regionCode']),
      postalAddressCity: str(postalAddress?['locality']),
      types: (json['types'] as List<dynamic>?)?.cast<String>(),

      // Address Components
      streetNumber: component('street_number'),
      route: component('route'),
      locality: component('locality'),
      administrativeAreaLevel1: component('administrative_area_level_1'),
      administrativeAreaLevel2: component('administrative_area_level_2'),
      country: component('country'),
      countryCode: componentShort('country'),
      postalCode: component('postal_code'),

      // Pro
      displayName: str(displayName?['text']),
      displayNameLanguageCode: str(displayName?['languageCode']),
      primaryType: str(json['primaryType']),
      primaryTypeDisplayName: str(primaryTypeDisplayName?['text']),
      businessStatus: str(json['businessStatus']),
      googleMapsUri: str(json['googleMapsUri']),
      iconBackgroundColor: str(json['iconBackgroundColor']),
      iconMaskBaseUri: str(json['iconMaskBaseUri']),
      timeZoneId: str((json['timeZone'] as Map<String, dynamic>?)?['id']),
      utcOffsetMinutes: integer(json['utcOffsetMinutes']),
      pureServiceAreaBusiness: boolean(json['pureServiceAreaBusiness']),
      openingDate: json['openingDate'] != null
          ? DateTime.tryParse(json['openingDate'] as String)
          : null,

      // Enterprise
      nationalPhoneNumber: str(json['nationalPhoneNumber']),
      internationalPhoneNumber: str(json['internationalPhoneNumber']),
      websiteUri: str(json['websiteUri']),
      rating: dbl(json['rating']),
      userRatingCount: integer(json['userRatingCount']),
      priceLevel: integer(json['priceLevel']),
      priceRangeMinPrice: dbl(
        (priceRange?['startPrice'] as Map<String, dynamic>?)?['units'],
      ),
      priceRangeMaxPrice: dbl(
        (priceRange?['endPrice'] as Map<String, dynamic>?)?['units'],
      ),
      priceRangeCurrency: str(
        (priceRange?['startPrice'] as Map<String, dynamic>?)?['currencyCode'],
      ),

      // Opening Hours (regular)
      regularOpeningHoursOpenNow: boolean(regularOpeningHours?['openNow']),
      regularOpeningHoursPeriods:
          (regularOpeningHours?['periods'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList(),
      regularOpeningHoursWeekdayDescriptions:
          (regularOpeningHours?['weekdayDescriptions'] as List<dynamic>?)
              ?.cast<String>(),

      // Opening Hours (current)
      currentOpeningHoursOpenNow: boolean(currentOpeningHours?['openNow']),
      currentOpeningHoursPeriods:
          (currentOpeningHours?['periods'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList(),
      currentOpeningHoursWeekdayDescriptions:
          (currentOpeningHours?['weekdayDescriptions'] as List<dynamic>?)
              ?.cast<String>(),

      // Atmosphere
      allowsDogs: boolean(json['allowsDogs']),
      curbsidePickup: boolean(json['curbsidePickup']),
      delivery: boolean(json['delivery']),
      dineIn: boolean(json['dineIn']),
      takeout: boolean(json['takeout']),
      reservable: boolean(json['reservable']),
      restroom: boolean(json['restroom']),
      goodForChildren: boolean(json['goodForChildren']),
      goodForGroups: boolean(json['goodForGroups']),
      goodForWatchingSports: boolean(json['goodForWatchingSports']),
      liveMusic: boolean(json['liveMusic']),
      menuForChildren: boolean(json['menuForChildren']),
      outdoorSeating: boolean(json['outdoorSeating']),
      servesBeer: boolean(json['servesBeer']),
      servesBreakfast: boolean(json['servesBreakfast']),
      servesBrunch: boolean(json['servesBrunch']),
      servesCocktails: boolean(json['servesCocktails']),
      servesCoffee: boolean(json['servesCoffee']),
      servesDessert: boolean(json['servesDessert']),
      servesDinner: boolean(json['servesDinner']),
      servesLunch: boolean(json['servesLunch']),
      servesVegetarianFood: boolean(json['servesVegetarianFood']),
      servesWine: boolean(json['servesWine']),

      // Accessibility
      wheelchairAccessibleEntrance: boolean(
        accessibilityOptions?['wheelchairAccessibleEntrance'],
      ),
      wheelchairAccessibleParking: boolean(
        accessibilityOptions?['wheelchairAccessibleParking'],
      ),
      wheelchairAccessibleRestroom: boolean(
        accessibilityOptions?['wheelchairAccessibleRestroom'],
      ),
      wheelchairAccessibleSeating: boolean(
        accessibilityOptions?['wheelchairAccessibleSeating'],
      ),

      // Parking
      freeParkingLot: boolean(parkingOptions?['freeParkingLot']),
      paidParkingLot: boolean(parkingOptions?['paidParkingLot']),
      freeStreetParking: boolean(parkingOptions?['freeStreetParking']),
      paidStreetParking: boolean(parkingOptions?['paidStreetParking']),
      valetParking: boolean(parkingOptions?['valetParking']),
      freeGarageParking: boolean(parkingOptions?['freeGarageParking']),
      paidGarageParking: boolean(parkingOptions?['paidGarageParking']),

      // Payment
      acceptsCashOnly: boolean(paymentOptions?['acceptsCashOnly']),
      acceptsCreditCards: boolean(paymentOptions?['acceptsCreditCards']),
      acceptsDebitCards: boolean(paymentOptions?['acceptsDebitCards']),
      acceptsNfc: boolean(paymentOptions?['acceptsNfc']),

      // Photos
      photoReferences: (json['photos'] as List<dynamic>?)
          ?.map((p) => (p as Map<String, dynamic>)['name'] as String)
          .toList(),

      // Summaries
      editorialSummary: str(editorialSummary?['text']),
      editorialSummaryLanguageCode: str(editorialSummary?['languageCode']),
      generativeSummary: str(
        (generativeSummary?['overview'] as Map<String, dynamic>?)?['text'],
      ),
      reviewSummary: str(reviewSummary?['text']),
      neighborhoodSummary: str(
        (neighborhoodSummary?['overview'] as Map<String, dynamic>?)?['text'],
      ),
    );
  }

  // IDs

  /// Unique place identifier used in further API calls.
  final String? id;

  /// Resource name of the place, e.g. `places/ChIJ...`.
  final String? name;

  // Essentials

  /// Full human-readable address of the place.
  final String? formattedAddress;

  /// Shortened formatted address suitable for compact display.
  final String? shortFormattedAddress;

  /// Address in adr microformat HTML.
  final String? adrFormatAddress;

  /// Latitude of the place's geographic center.
  final double? latitude;

  /// Longitude of the place's geographic center.
  final double? longitude;

  /// Northern latitude bound of the recommended viewport.
  final double? viewportNorthLat;

  /// Northern longitude bound of the recommended viewport.
  final double? viewportNorthLng;

  /// Southern latitude bound of the recommended viewport.
  final double? viewportSouthLat;

  /// Southern longitude bound of the recommended viewport.
  final double? viewportSouthLng;

  /// Global Plus Code for the place location.
  final String? plusCodeGlobal;

  /// Compound Plus Code for the place location.
  final String? plusCodeCompound;

  /// Administrative area from the place's postal address.
  final String? postalAddressRegion;

  /// Postal code from the place's postal address.
  final String? postalAddressPostalCode;

  /// Country code from the place's postal address.
  final String? postalAddressCountry;

  /// City/locality from the place's postal address.
  final String? postalAddressCity;

  /// List of place type strings, e.g. `["restaurant", "food"]`.
  final List<String>? types;

  // Address Components

  /// Street number component of the address.
  final String? streetNumber;

  /// Street name component of the address.
  final String? route;

  /// City or town component of the address.
  final String? locality;

  /// State or province component of the address.
  final String? administrativeAreaLevel1;

  /// County or district component of the address.
  final String? administrativeAreaLevel2;

  /// Full country name, e.g. `"United States"`.
  final String? country;

  /// ISO 3166-1 alpha-2 country code, e.g. `"US"`.
  final String? countryCode;

  /// Postal/ZIP code component of the address.
  final String? postalCode;

  // Pro

  /// Human-readable display name of the place.
  final String? displayName;

  /// BCP-47 language code of the [displayName].
  final String? displayNameLanguageCode;

  /// Primary place type identifier string.
  final String? primaryType;

  /// Localized display name of the primary place type.
  final String? primaryTypeDisplayName;

  /// Operational status, e.g. `"OPERATIONAL"` or `"CLOSED_PERMANENTLY"`.
  final String? businessStatus;

  /// Deep link to the place on Google Maps.
  final String? googleMapsUri;

  /// Background color to use with the place icon.
  final String? iconBackgroundColor;

  /// Base URI for the place's category icon mask.
  final String? iconMaskBaseUri;

  /// IANA time-zone ID for the place, e.g. `"America/New_York"`.
  final String? timeZoneId;

  /// UTC offset of the place's time zone in minutes.
  final int? utcOffsetMinutes;

  /// Whether the business serves customers only at their locations,
  /// not at a fixed address.
  final bool? pureServiceAreaBusiness;

  /// Date the place originally opened.
  final DateTime? openingDate;

  // Enterprise

  /// Local phone number in national format.
  final String? nationalPhoneNumber;

  /// International phone number in E.164 format.
  final String? internationalPhoneNumber;

  /// Website URI for the place.
  final String? websiteUri;

  /// Average user rating on a scale of 1.0–5.0.
  final double? rating;

  /// Total number of user ratings contributing to [rating].
  final int? userRatingCount;

  /// Price level on a 0–4 integer scale.
  final int? priceLevel;

  /// Minimum price in the place's price range.
  final double? priceRangeMinPrice;

  /// Maximum price in the place's price range.
  final double? priceRangeMaxPrice;

  /// ISO 4217 currency code for the price range.
  final String? priceRangeCurrency;

  // Opening Hours (regular)

  /// Whether the place is currently open during its regular hours.
  final bool? regularOpeningHoursOpenNow;

  /// Serialized period objects describing regular opening hours.
  final List<String>? regularOpeningHoursPeriods;

  /// Human-readable weekday descriptions for regular opening hours.
  final List<String>? regularOpeningHoursWeekdayDescriptions;

  // Opening Hours (current)

  /// Whether the place is open right now, accounting for special hours.
  final bool? currentOpeningHoursOpenNow;

  /// Serialized period objects for current (possibly special) opening hours.
  final List<String>? currentOpeningHoursPeriods;

  /// Human-readable weekday descriptions for current opening hours.
  final List<String>? currentOpeningHoursWeekdayDescriptions;

  // Atmosphere / Enterprise+

  /// Whether the place allows dogs.
  final bool? allowsDogs;

  /// Whether the place offers curbside pickup.
  final bool? curbsidePickup;

  /// Whether the place offers delivery.
  final bool? delivery;

  /// Whether the place offers dine-in service.
  final bool? dineIn;

  /// Whether the place offers takeout.
  final bool? takeout;

  /// Whether the place accepts reservations.
  final bool? reservable;

  /// Whether the place has a public restroom.
  final bool? restroom;

  /// Whether the place is good for children.
  final bool? goodForChildren;

  /// Whether the place is good for groups.
  final bool? goodForGroups;

  /// Whether the place is good for watching sports.
  final bool? goodForWatchingSports;

  /// Whether the place has live music.
  final bool? liveMusic;

  /// Whether the place has a menu for children.
  final bool? menuForChildren;

  /// Whether the place has outdoor seating.
  final bool? outdoorSeating;

  /// Whether the place serves beer.
  final bool? servesBeer;

  /// Whether the place serves breakfast.
  final bool? servesBreakfast;

  /// Whether the place serves brunch.
  final bool? servesBrunch;

  /// Whether the place serves cocktails.
  final bool? servesCocktails;

  /// Whether the place serves coffee.
  final bool? servesCoffee;

  /// Whether the place serves dessert.
  final bool? servesDessert;

  /// Whether the place serves dinner.
  final bool? servesDinner;

  /// Whether the place serves lunch.
  final bool? servesLunch;

  /// Whether the place serves vegetarian food.
  final bool? servesVegetarianFood;

  /// Whether the place serves wine.
  final bool? servesWine;

  // Accessibility

  /// Whether the place has a wheelchair-accessible entrance.
  final bool? wheelchairAccessibleEntrance;

  /// Whether the place has wheelchair-accessible parking.
  final bool? wheelchairAccessibleParking;

  /// Whether the place has a wheelchair-accessible restroom.
  final bool? wheelchairAccessibleRestroom;

  /// Whether the place has wheelchair-accessible seating.
  final bool? wheelchairAccessibleSeating;

  // Parking

  /// Whether the place has a free parking lot.
  final bool? freeParkingLot;

  /// Whether the place has a paid parking lot.
  final bool? paidParkingLot;

  /// Whether free street parking is available nearby.
  final bool? freeStreetParking;

  /// Whether paid street parking is available nearby.
  final bool? paidStreetParking;

  /// Whether valet parking is available.
  final bool? valetParking;

  /// Whether the place has a free parking garage.
  final bool? freeGarageParking;

  /// Whether the place has a paid parking garage.
  final bool? paidGarageParking;

  // Payment

  /// Whether the place accepts cash only.
  final bool? acceptsCashOnly;

  /// Whether the place accepts credit cards.
  final bool? acceptsCreditCards;

  /// Whether the place accepts debit cards.
  final bool? acceptsDebitCards;

  /// Whether the place accepts NFC payments.
  final bool? acceptsNfc;

  // Photos

  /// Resource name strings for the place's photos.
  final List<String>? photoReferences;

  // Editorial / AI summaries

  /// Human-written editorial summary of the place.
  final String? editorialSummary;

  /// BCP-47 language code of the [editorialSummary].
  final String? editorialSummaryLanguageCode;

  /// AI-generated overview summary of the place.
  final String? generativeSummary;

  /// AI-generated summary of user reviews.
  final String? reviewSummary;

  /// AI-generated summary of the surrounding neighborhood.
  final String? neighborhoodSummary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceDetails &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
