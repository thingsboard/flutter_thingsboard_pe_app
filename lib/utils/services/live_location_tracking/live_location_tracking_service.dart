import 'dart:async';

import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_entity_name_resolver.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_location_tracking_service.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_notifications.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_remote.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_store.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/last_tracking_record.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_config.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_error.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_session.dart';
import 'package:thingsboard_app/utils/services/location/i_location_service.dart';
import 'package:thingsboard_app/utils/services/location/model/geo_position.dart';
import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';
import 'package:thingsboard_app/utils/services/location/model/location_stream_settings.dart';

class LiveLocationTrackingService implements ILiveLocationTrackingService {
  LiveLocationTrackingService({
    required ILocationService locationService,
    required ILiveTrackingRemote remote,
    required TbLogger logger,
    required ILiveTrackingStore store,
    required IEntityNameResolver nameResolver,
    required ILiveTrackingNotifications notifications,
    // Android notification strings are OS-level, set once at construction;
    // English defaults are acceptable for v1 (the locator can later pass
    // localized strings without touching this class).
    this.backgroundConfig = const BackgroundTrackingConfig(
      notificationTitle: 'ThingsBoard',
      notificationText: 'Live location tracking is active',
    ),
  }) : _locationService = locationService,
       _remote = remote,
       _log = logger,
       _store = store,
       _nameResolver = nameResolver,
       _notifications = notifications;

  final ILocationService _locationService;
  final ILiveTrackingRemote _remote;
  final TbLogger _log;
  final ILiveTrackingStore _store;
  final IEntityNameResolver _nameResolver;
  final ILiveTrackingNotifications _notifications;
  final BackgroundTrackingConfig backgroundConfig;

  final _sessionController = StreamController<LiveTrackingSession?>.broadcast();
  LiveTrackingSession? _session;
  StreamSubscription<LocationFix>? _subscription;
  Timer? _maxDurationTimer;

  @override
  LiveTrackingSession? get session => _session;

  @override
  Stream<LiveTrackingSession?> get sessionStream => _sessionController.stream;

  @override
  Future<void> start(LiveTrackingConfig config) async {
    await stop();
    final startedAt = DateTime.now();
    _setSession(
      LiveTrackingSession(
        config: config,
        status: LiveTrackingStatus.tracking,
        startedAt: startedAt,
      ),
    );
    // Persist the recoverable "interrupted" record and subscribe to GPS
    // before doing anything network-bound: a force-kill or a race with
    // stop()/logout must never leave this critical path gated on the
    // (possibly slow or offline) entity-name lookup below.
    await _store.write(
      LastTrackingRecord(
        configJson: config.toJson(),
        targetName: config.targetName,
        startedAt: startedAt,
        endReason: TrackingEndReason.interrupted,
      ),
    );
    await _writeTrackingStatus(active: true, includeTrackedBy: true);
    _subscribe(config);
    final maxDuration = config.maxDurationSeconds;
    if (maxDuration != null) {
      _maxDurationTimer = Timer(
        Duration(seconds: maxDuration),
        () => _finish(TrackingEndReason.maxDuration),
      );
    }
    unawaited(_resolveAndPatchTargetName(config, startedAt));
  }

  /// Resolves the human-readable target name off the critical path and
  /// patches it into the persisted record once known. Guarded against the
  /// session having been stopped/replaced while the (network) lookup was in
  /// flight, so a late resolution can never resurrect a stopped session's
  /// record or re-subscribe GPS after stop()/logout.
  Future<void> _resolveAndPatchTargetName(
    LiveTrackingConfig config,
    DateTime startedAt,
  ) async {
    final name = await _nameResolver.resolveName(
      config.target.entityType,
      config.target.id,
    );
    if (name == null) {
      return;
    }
    if (_session?.startedAt != startedAt) {
      return;
    }
    final existing = await _store.read();
    if (existing == null) {
      return;
    }
    // Re-check after the read() await: stop()/logout may have finished (and
    // cleared the store) while we were reading, and we must not resurrect a
    // stopped session's record with a late write.
    if (_session?.startedAt != startedAt) {
      return;
    }
    await _store.write(existing.copyWith(targetName: name));
  }

  @override
  Future<void> stop() => _finish(TrackingEndReason.manual);

  Future<void> _finish(TrackingEndReason reason) async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    _cancelSubscription();
    final current = _session;
    if (current != null) {
      await _notifications.clear();
      await _writeTrackingStatus(active: false);
      await _updateRecordOnEnd(current, reason);
      _setSession(null);
    }
  }

  Future<void> _updateRecordOnEnd(
    LiveTrackingSession session,
    TrackingEndReason reason,
  ) async {
    final existing = await _store.read();
    if (existing == null) {
      return;
    }
    await _store.write(
      existing.copyWith(
        endedAt: DateTime.now(),
        fixCount: session.fixCount,
        savedCount: session.savedCount,
        saveErrorCount: session.saveErrorCount,
        lastLat: session.lastFix?.latitude,
        lastLng: session.lastFix?.longitude,
        lastError: session.lastError?.name,
        endReason: reason,
      ),
    );
  }

  @override
  Future<void> pause() async {
    final current = _session;
    if (current == null || current.status != LiveTrackingStatus.tracking) {
      return;
    }
    _cancelSubscription();
    _setSession(current.copyWith(status: LiveTrackingStatus.paused));
    await _notifications.showPaused(targetName: current.config.targetName);
    await _writeTrackingStatus(active: false);
  }

  @override
  Future<void> resume() async {
    final current = _session;
    if (current == null || current.status != LiveTrackingStatus.paused) {
      return;
    }
    _setSession(
      current.copyWith(status: LiveTrackingStatus.tracking, lastError: null),
    );
    await _notifications.clear();
    await _writeTrackingStatus(active: true, includeTrackedBy: true);
    _subscribe(current.config);
  }

  void _subscribe(LiveTrackingConfig config) {
    _subscription = _locationService
        .positionStream(
          settings: LocationStreamSettings(
            accuracy: config.accuracy,
            distanceFilterMeters: config.distanceFilterMeters ?? 0,
            interval:
                config.intervalSeconds != null
                    ? Duration(seconds: config.intervalSeconds!)
                    : null,
            background: backgroundConfig,
          ),
        )
        .listen(_onFix);
  }

  Future<void> _onFix(LocationFix fix) async {
    final current = _session;
    if (current == null) {
      return;
    }
    switch (fix) {
      case LocationSuccess(:final position):
        // A successful fix means the previously reported problem is over;
        // a still-failing save below re-raises its own error.
        _setSession(
          current.copyWith(
            fixCount: current.fixCount + 1,
            lastFix: position,
            lastError: null,
          ),
        );
        await _saveFix(current.config, position);
      case LocationServicesDisabled():
        await _pauseWithError(LiveTrackingError.locationServicesDisabled);
      case LocationPermissionDenied():
        await _pauseWithError(LiveTrackingError.locationPermissionDenied);
      case LocationPermissionDeniedForever():
        await _pauseWithError(
          LiveTrackingError.locationPermissionDeniedForever,
        );
      case LocationFixError():
        _setSession(
          _session?.copyWith(lastError: LiveTrackingError.locationError),
        );
    }
  }

  Future<void> _saveFix(LiveTrackingConfig config, GeoPosition position) async {
    final ts = (position.timestamp ?? DateTime.now()).millisecondsSinceEpoch;
    try {
      await _save(config, {
        LiveTrackingKeyType.latitude: position.latitude,
        LiveTrackingKeyType.longitude: position.longitude,
        LiveTrackingKeyType.accuracy: position.accuracy,
        LiveTrackingKeyType.altitude: position.altitude,
        LiveTrackingKeyType.speed: position.speed,
        LiveTrackingKeyType.heading: position.heading,
      }, ts: ts);
      final current = _session;
      if (current != null) {
        _setSession(current.copyWith(savedCount: current.savedCount + 1));
      }
    } catch (e, s) {
      _log.error('LiveLocationTrackingService: save failed', e, s);
      final current = _session;
      if (current != null) {
        _setSession(
          current.copyWith(
            saveErrorCount: current.saveErrorCount + 1,
            lastError: LiveTrackingError.fromSaveException(e),
          ),
        );
      }
    }
  }

  Future<void> _pauseWithError(LiveTrackingError error) async {
    final current = _session;
    if (current == null) {
      return;
    }
    _cancelSubscription();
    _setSession(
      current.copyWith(status: LiveTrackingStatus.paused, lastError: error),
    );
    await _notifications.showPaused(targetName: current.config.targetName);
    await _writeTrackingStatus(active: false);
  }

  /// Fire-and-forget teardown: [StreamSubscription.cancel] detaches the
  /// listener synchronously, so awaiting its completion would only gate on the
  /// plugin's native teardown — which we don't need to block session state on.
  void _cancelSubscription() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  Future<void> _writeTrackingStatus({
    required bool active,
    bool includeTrackedBy = false,
  }) async {
    final config = _session?.config;
    if (config == null) {
      return;
    }
    try {
      await _save(config, {
        LiveTrackingKeyType.gpsActive: active,
        if (includeTrackedBy)
          LiveTrackingKeyType.gpsTrackedBy: config.trackedBy,
      });
    } catch (e, s) {
      _log.error('LiveLocationTrackingService: tracking status failed', e, s);
    }
  }

  /// Routes each configured key to attributes or time series under the label
  /// the dashboard resolved for it. Values the dashboard did not ask for — and
  /// values the device could not provide — are skipped.
  Future<void> _save(
    LiveTrackingConfig config,
    Map<LiveTrackingKeyType, dynamic> values, {
    int? ts,
  }) async {
    final attributes = <String, dynamic>{};
    final telemetry = <String, dynamic>{};
    for (final key in config.keys) {
      final value = values[key.key];
      if (value == null) {
        continue;
      }
      switch (key.valueType) {
        case LiveTrackingValueType.attribute:
          attributes[key.label] = value;
        case LiveTrackingValueType.timeseries:
          telemetry[key.label] = value;
      }
    }
    if (telemetry.isNotEmpty) {
      await _remote.saveTelemetry(
        config.target,
        ts ?? DateTime.now().millisecondsSinceEpoch,
        telemetry,
      );
    }
    if (attributes.isNotEmpty) {
      await _remote.saveAttributes(config.target, attributes);
    }
  }

  void _setSession(LiveTrackingSession? session) {
    _session = session;
    _sessionController.add(session);
  }
}
