import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo_position.freezed.dart';

/// Plugin-agnostic GPS position. Keeps `package:geolocator`'s `Position`
/// type from leaking past the location service boundary.
@freezed
abstract class GeoPosition with _$GeoPosition {
  const factory GeoPosition({
    required double latitude,
    required double longitude,
    required double accuracy,
    DateTime? timestamp,
    double? altitude,
    double? speed,
    double? heading,
  }) = _GeoPosition;
}
