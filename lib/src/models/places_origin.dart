/// Geographic origin point from which straight-line distances to place
/// predictions are calculated.
class PlacesOrigin {
  /// Creates a [PlacesOrigin] at the given [latitude] and [longitude].
  const PlacesOrigin({required this.latitude, required this.longitude});

  /// Latitude of the origin point.
  final double latitude;

  /// Longitude of the origin point.
  final double longitude;

  /// Serializes this origin to the JSON shape expected by the Places API.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
