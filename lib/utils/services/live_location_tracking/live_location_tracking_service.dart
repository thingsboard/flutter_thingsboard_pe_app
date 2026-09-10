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
  Future<void> _storeWrites = Future<void>.value();

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
    // Persist the recoverable "interrupted" record before doing anything
    // network-bound: a force-kill must never leave the record gated on the
    // (possibly slow or offline) entity-name lookup below.
    await _writeRecord(
      LastTrackingRecord(
        configJson: config.toJson(),
        targetName: config.targetName,
        startedAt: startedAt,
        endReason: TrackingEndReason.interrupted,
      ),
    );
    await _writeTrackingStatus(active: true, includeTrackedBy: true);
    // The writes above include a network round trip, so stop(), a
    // stopLiveLocation action or logout may have torn this session down
    // meanwhile. Subscribing now would leave a GPS stream — and on Android
    // the foreground service with its "active" notification — running with no
    // session to cancel it, invisible to the UI even after logout.
    if (!_isCurrent(startedAt)) {
      return;
    }
    _subscribe(config);
    final maxDuration = config.maxDurationSeconds;
    if (maxDuration != null && maxDuration > 0) {
      _maxDurationTimer = Timer(
        Duration(seconds: maxDuration),
        () => _finish(TrackingEndReason.maxDuration),
      );
    }
    unawaited(_resolveAndPatchTargetName(config, startedAt));
  }

  /// A session is identified by its [LiveTrackingSession.startedAt]. Every
  /// step that resumes after an `await` re-checks it, because a stop, a pause
  /// or a newer `start()` may have replaced the session while the await was in
  /// flight.
  bool _isCurrent(DateTime startedAt) => _session?.startedAt == startedAt;

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
    await _mutateRecord((existing) {
      // The record may already belong to a later session by the time this
      // patch runs; only the one this lookup was started for may be touched.
      if (existing.startedAt != startedAt) {
        return null;
      }
      return existing.copyWith(targetName: name);
    });
  }

  @override
  Future<void> stop() => _finish(TrackingEndReason.manual);

  @override
  Future<void> teardownForLogout() async {
    try {
      await stop();
      await _queueStoreWrite(_store.clear);
    } catch (e, s) {
      // The user asked to log out: a teardown failure is worth a log, never a
      // blocked logout.
      _log.error('LiveLocationTrackingService: logout teardown failed', e, s);
    }
  }

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
  ) => _mutateRecord(
    (existing) => existing.copyWith(
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

  /// Record updates are read-modify-write on a single storage key, and
  /// [ILiveTrackingStore] serializes nothing, so they are queued here: a late
  /// `targetName` patch must not write a pre-end snapshot back over the
  /// finalized record, nor resurrect a record that logout has cleared.
  Future<void> _queueStoreWrite(Future<void> Function() write) {
    final queued = _storeWrites.then((_) => write());
    // Keep the queue usable: a failure must not reject every write after it.
    _storeWrites = queued.catchError((_) {});
    return queued;
  }

  Future<void> _writeRecord(LastTrackingRecord record) =>
      _queueStoreWrite(() => _store.write(record));

  /// Applies [mutate] to the stored record. Returning `null` from [mutate]
  /// leaves the record untouched.
  Future<void> _mutateRecord(
    LastTrackingRecord? Function(LastTrackingRecord existing) mutate,
  ) => _queueStoreWrite(() async {
    final existing = await _store.read();
    if (existing == null) {
      return;
    }
    final updated = mutate(existing);
    if (updated != null) {
      await _store.write(updated);
    }
  });

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
    // Same window as in start(): a stop or a re-pause during the network
    // write above must not be followed by a subscription nothing owns.
    if (!_isCurrent(current.startedAt) ||
        _session?.status != LiveTrackingStatus.tracking) {
      return;
    }
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
        .listen(
          _onFix,
          onError: (Object e, StackTrace s) {
            _log.error(
              'LiveLocationTrackingService: location stream failed',
              e,
              s,
            );
            unawaited(_pauseWithError(LiveTrackingError.locationError));
          },
          // A completed stream delivers no further fixes. Without this the
          // session would sit at "tracking" forever with a dead stream. A
          // terminal failure fix arrives before the completion and has
          // already paused with its own cause, which pause() leaves intact.
          onDone: () => unawaited(pause()),
        );
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
        // Individual fixes fail transiently (a tunnel, a cold GPS start), so
        // the cause is recorded for the session screen and the stream is left
        // to recover on the next fix.
        _setSession(
          _session?.copyWith(lastError: LiveTrackingError.locationError),
        );
    }
  }

  Future<void> _saveFix(LiveTrackingConfig config, GeoPosition position) async {
    try {
      final saved = await _save(
        config,
        _fixValues(position),
        ts: position.timestamp.millisecondsSinceEpoch,
      );
      final current = _session;
      // A config mapping no position key issues no request at all; counting
      // that as saved would report "Saved: N" for a session that wrote
      // nothing.
      if (saved && current != null) {
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

  /// The value each key takes from a fix, built through an exhaustive switch:
  /// the enum mirrors the web-side `LocationKey` and will grow, and a
  /// hand-maintained map would let a new key be configurable on the dashboard
  /// yet silently never written. The two session status keys belong to
  /// [_writeTrackingStatus], not to a fix.
  Map<LiveTrackingKeyType, Object?> _fixValues(GeoPosition position) => {
    for (final key in LiveTrackingKeyType.values)
      key: switch (key) {
        LiveTrackingKeyType.latitude => position.latitude,
        LiveTrackingKeyType.longitude => position.longitude,
        LiveTrackingKeyType.accuracy => position.accuracy,
        LiveTrackingKeyType.altitude => position.altitude,
        LiveTrackingKeyType.speed => position.speed,
        LiveTrackingKeyType.heading => position.heading,
        LiveTrackingKeyType.gpsActive ||
        LiveTrackingKeyType.gpsTrackedBy => null,
      },
  };

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
  /// the dashboard resolved for it. Keys this write does not carry — the
  /// status keys on a fix, an unset `trackedBy` — are skipped. Returns
  /// whether a request was actually issued.
  Future<bool> _save(
    LiveTrackingConfig config,
    Map<LiveTrackingKeyType, Object?> values, {
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
    return telemetry.isNotEmpty || attributes.isNotEmpty;
  }

  void _setSession(LiveTrackingSession? session) {
    _session = session;
    _sessionController.add(session);
  }
}
