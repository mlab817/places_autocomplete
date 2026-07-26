/// Restricts autocomplete results strictly to a circular or rectangular region.
class PlacesLocationRestriction {
  const PlacesLocationRestriction._({
    required _PlacesLocationRestrictionType type,
    this.circleLat,
    this.circleLng,
    this.circleRadius,
    this.rectLowLat,
    this.rectLowLng,
    this.rectHighLat,
    this.rectHighLng,
  }) : _type = type;

  /// Creates a circular restriction centered at ([latitude], [longitude])
  /// with the given [radius] in meters (1–50000).
  factory PlacesLocationRestriction.circle({
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    assert(
      radius > 0 && radius <= 50000,
      'Radius must be between 0 and 50000 meters.',
    );
    return PlacesLocationRestriction._(
      type: _PlacesLocationRestrictionType.circle,
      circleLat: latitude,
      circleLng: longitude,
      circleRadius: radius,
    );
  }

  /// Creates a rectangular restriction defined by the given bounding box.
  factory PlacesLocationRestriction.rectangle({
    required double lowLatitude,
    required double lowLongitude,
    required double highLatitude,
    required double highLongitude,
  }) {
    return PlacesLocationRestriction._(
      type: _PlacesLocationRestrictionType.rectangle,
      rectLowLat: lowLatitude,
      rectLowLng: lowLongitude,
      rectHighLat: highLatitude,
      rectHighLng: highLongitude,
    );
  }

  /// Latitude of the circle center.
  final double? circleLat;

  /// Longitude of the circle center.
  final double? circleLng;

  /// Radius of the circle in meters.
  final double? circleRadius;

  /// Southern latitude bound of the rectangle.
  final double? rectLowLat;

  /// Western longitude bound of the rectangle.
  final double? rectLowLng;

  /// Northern latitude bound of the rectangle.
  final double? rectHighLat;

  /// Eastern longitude bound of the rectangle.
  final double? rectHighLng;

  final _PlacesLocationRestrictionType _type;

  /// Serializes this restriction to the JSON shape expected by the Places API.
  Map<String, dynamic> toJson() {
    switch (_type) {
      case _PlacesLocationRestrictionType.circle:
        return {
          'circle': {
            'center': {'latitude': circleLat, 'longitude': circleLng},
            'radius': circleRadius,
          },
        };
      case _PlacesLocationRestrictionType.rectangle:
        return {
          'rectangle': {
            'low': {'latitude': rectLowLat, 'longitude': rectLowLng},
            'high': {'latitude': rectHighLat, 'longitude': rectHighLng},
          },
        };
    }
  }
}

enum _PlacesLocationRestrictionType { circle, rectangle }
