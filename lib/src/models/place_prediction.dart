import 'package:flutter/widgets.dart';

/// Represents a single place prediction returned from the Google Places
/// Autocomplete API.
@immutable
class PlacePrediction {
  /// Creates a [PlacePrediction].
  const PlacePrediction({
    required this.placeId,
    required this.name,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
    this.distanceMeters,
  });

  /// Parses a [PlacePrediction] from the raw JSON of a single suggestion entry.
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final placePrediction = json['placePrediction'] as Map<String, dynamic>;
    final structuredFormat =
        placePrediction['structuredFormat'] as Map<String, dynamic>? ?? {};

    return PlacePrediction(
      placeId: placePrediction['placeId'] as String? ?? '',
      name: placePrediction['place'] as String? ?? '',
      description: (placePrediction['text'] as Map<String, dynamic>?)?['text']
              as String? ??
          '',
      mainText: (structuredFormat['mainText'] as Map<String, dynamic>?)?['text']
              as String? ??
          '',
      secondaryText: (structuredFormat['secondaryText']
              as Map<String, dynamic>?)?['text'] as String? ??
          '',
      types: (placePrediction['types'] as List<dynamic>?)?.cast<String>() ?? [],
      distanceMeters: placePrediction['distanceMeters'] as int?,
    );
  }

  /// The unique identifier of the predicted place.
  final String placeId;

  /// The resource name of the predicted place. e.g. places/ChIJ...
  final String name;

  /// The full human-readable description of the place.
  /// e.g. "Amoeba Music, Haight Street, San Francisco, CA, USA"
  final String description;

  /// The primary part of the description, usually the place name.
  /// e.g. "Amoeba Music"
  final String mainText;

  /// The secondary part of the description, usually the address.
  /// e.g. "Haight Street, San Francisco, CA, USA"
  final String secondaryText;

  /// The place types associated with this prediction.
  /// e.g. ["establishment", "point_of_interest"]
  final List<String> types;

  /// Straight-line distance in meters from the origin to this place.
  /// Only populated if an origin is set on the controller.
  final int? distanceMeters;

  /// Returns a copy of this prediction with the given fields replaced.
  PlacePrediction copyWith({
    String? placeId,
    String? name,
    String? description,
    String? mainText,
    String? secondaryText,
    List<String>? types,
    int? distanceMeters,
  }) {
    return PlacePrediction(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      description: description ?? this.description,
      mainText: mainText ?? this.mainText,
      secondaryText: secondaryText ?? this.secondaryText,
      types: types ?? this.types,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlacePrediction &&
          runtimeType == other.runtimeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;
}
