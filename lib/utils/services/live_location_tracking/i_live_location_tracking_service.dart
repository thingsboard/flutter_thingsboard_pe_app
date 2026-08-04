import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_config.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_session.dart';

/// App-wide owner of at most one live GPS tracking session. Runs the
/// location stream, saves telemetry/attributes per fix, and exposes session
/// state for the tracking bar / session screen.
abstract interface class ILiveLocationTrackingService {
  LiveTrackingSession? get session;

  /// Emits on every session change; emits `null` when tracking stops.
  Stream<LiveTrackingSession?> get sessionStream;

  /// Starts a session, replacing any active one.
  Future<void> start(LiveTrackingConfig config);

  Future<void> stop();

  /// Suspends position updates without discarding the session; writes
  /// `gpsActive=false` so the platform sees data flow honestly stopped.
  Future<void> pause();

  Future<void> resume();
}
