import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/utils/services/location/i_location_service.dart';
import 'package:thingsboard_app/utils/services/location/model/geo_position.dart';
import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';

class LocationService implements ILocationService {
  LocationService({required TbLogger logger, GeolocatorPlatform? geolocator})
    : _log = logger,
      _geolocator = geolocator ?? GeolocatorPlatform.instance;

  final TbLogger _log;
  final GeolocatorPlatform _geolocator;

  @override
  Future<LocationFix> getCurrentPosition() async {
    try {
      final unavailable = await _ensureAvailable();
      if (unavailable != null) {
        return unavailable;
      }

      final position = await _geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return LocationSuccess(_toGeoPosition(position));
    } catch (e, s) {
      _log.error('LocationService.getCurrentPosition failed', e, s);
      return LocationFixError(e.toString());
    }
  }

  @override
  Stream<LocationFix> positionStream({double distanceFilterMeters = 0}) async* {
    final unavailable = await _ensureAvailable();
    if (unavailable != null) {
      yield unavailable;
      return;
    }

    final raw = _geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters.round(),
      ),
    );

    yield* raw.transform(
      StreamTransformer<Position, LocationFix>.fromHandlers(
        handleData:
            (position, sink) =>
                sink.add(LocationSuccess(_toGeoPosition(position))),
        handleError: (e, s, sink) {
          _log.error('LocationService.positionStream error', e, s);
          sink.add(LocationFixError(e.toString()));
        },
      ),
    );
  }

  @override
  Future<bool> openLocationSettings() => _geolocator.openLocationSettings();

  @override
  Future<bool> openAppSettings() => _geolocator.openAppSettings();

  /// Returns `null` when location is available, otherwise a failure
  /// [LocationFix] describing why it is not.
  Future<LocationFix?> _ensureAvailable() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationServicesDisabled();
    }

    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationPermissionDenied();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationPermissionDeniedForever();
    }
    return null;
  }

  GeoPosition _toGeoPosition(Position p) => GeoPosition(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracy: p.accuracy,
    timestamp: p.timestamp,
  );
}
