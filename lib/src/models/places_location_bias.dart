/// Biases autocomplete results toward a circular or rectangular region
/// without strictly excluding results outside it.
class PlacesLocationBias {
  const PlacesLocationBias._({
    required _PlacesLocationBiasType type,
    this.circleLat,
    this.circleLng,
    this.circleRadius,
    this.rectLowLat,
    this.rectLowLng,
    this.rectHighLat,
    this.rectHighLng,
  }) : _type = type;

  /// Creates a circular location bias centered at ([latitude], [longitude])
  /// with the given [radius] in meters (0–50000).
  factory PlacesLocationBias.circle({
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    assert(
      radius >= 0 && radius <= 50000,
      'Radius must be between 0 and 50000 meters.',
    );
    return PlacesLocationBias._(
      type: _PlacesLocationBiasType.circle,
      circleLat: latitude,
      circleLng: longitude,
      circleRadius: radius,
    );
  }

  /// Creates a rectangular location bias defined by the given bounding box.
  factory PlacesLocationBias.rectangle({
    required double lowLatitude,
    required double lowLongitude,
    required double highLatitude,
    required double highLongitude,
  }) {
    return PlacesLocationBias._(
      type: _PlacesLocationBiasType.rectangle,
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

  final _PlacesLocationBiasType _type;

  /// Serializes this bias to the JSON shape expected by the Places API.
  Map<String, dynamic> toJson() {
    switch (_type) {
      case _PlacesLocationBiasType.circle:
        return {
          'circle': {
            'center': {'latitude': circleLat, 'longitude': circleLng},
            'radius': circleRadius,
          },
        };
      case _PlacesLocationBiasType.rectangle:
        return {
          'rectangle': {
            'low': {'latitude': rectLowLat, 'longitude': rectLowLng},
            'high': {'latitude': rectHighLat, 'longitude': rectHighLng},
          },
        };
    }
  }
}

enum _PlacesLocationBiasType { circle, rectangle }
