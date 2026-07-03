import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';

/// Single entry point for GPS access across the app. Implementations own all
/// permission / service-enabled handling so callers never touch the geolocator
/// plugin directly.
abstract interface class ILocationService {
  /// Resolves a single current position, performing the full permission and
  /// service-enabled checks internally.
  Future<LocationFix> getCurrentPosition();

  /// Foreground live position updates. Pre-checks availability, then relays
  /// each update as a [LocationSuccess]. Emits a terminal failure [LocationFix]
  /// (and stops) if location is unavailable. Subscribers must cancel their
  /// [StreamSubscription] when done (Riverpod/Bloc disposal handles this).
  Stream<LocationFix> positionStream({double distanceFilterMeters = 0});

  /// Opens the OS location settings screen. Returns true if it was opened.
  Future<bool> openLocationSettings();

  /// Opens this app's settings screen (for permanently-denied permission).
  Future<bool> openAppSettings();
}
