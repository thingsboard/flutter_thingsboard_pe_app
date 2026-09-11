import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_entity_name_resolver.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_notifications.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_remote.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_store.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/live_location_tracking_service.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/last_tracking_record.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_config.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_session.dart';
import 'package:thingsboard_app/utils/services/location/i_location_service.dart';
import 'package:thingsboard_app/utils/services/location/model/geo_position.dart';
import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';
import 'package:thingsboard_app/utils/services/location/model/location_stream_settings.dart';

import '../../../helpers/test_dependencies.dart';

class MockLocationService extends Mock implements ILocationService {}

class MockLiveTrackingRemote extends Mock implements ILiveTrackingRemote {}

class MockEntityNameResolver extends Mock implements IEntityNameResolver {}

class MockLiveTrackingNotifications extends Mock
    implements ILiveTrackingNotifications {}

/// A real in-memory store rather than a mock: every race covered here is a
/// read-modify-write pair on the one record key, which a stubbed `read()`
/// cannot reproduce.
class InMemoryStore implements ILiveTrackingStore {
  LastTrackingRecord? record;

  @override
  Future<void> clear() async {
    record = null;
  }

  @override
  Future<LastTrackingRecord?> read() async => record;

  @override
  Future<void> write(LastTrackingRecord record) async {
    this.record = record;
  }
}

const target = LiveTrackingTarget(entityType: 'DEVICE', id: 'device-1');

/// Position keys as time series and `gpsActive` as an attribute, which is how
/// the dashboard maps a tracking widget action.
LiveTrackingConfig trackingConfig() => const LiveTrackingConfig(
  target: target,
  keys: [
    LiveTrackingKey(
      key: LiveTrackingKeyType.latitude,
      label: 'latitude',
      valueType: LiveTrackingValueType.timeseries,
    ),
    LiveTrackingKey(
      key: LiveTrackingKeyType.longitude,
      label: 'longitude',
      valueType: LiveTrackingValueType.timeseries,
    ),
    LiveTrackingKey(
      key: LiveTrackingKeyType.gpsActive,
      label: 'gpsActive',
      valueType: LiveTrackingValueType.attribute,
    ),
  ],
  trackedBy: 'tester',
);

LocationSuccess fixAt(double latitude, double longitude) => LocationSuccess(
  GeoPosition(
    latitude: latitude,
    longitude: longitude,
    accuracy: 5,
    timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    altitude: 0,
    speed: 0,
    heading: 0,
  ),
);

void main() {
  late MockLocationService locationService;
  late MockLiveTrackingRemote remote;
  late MockEntityNameResolver nameResolver;
  late MockLiveTrackingNotifications notifications;
  late InMemoryStore store;

  /// One controller per `positionStream()` call, so a replaced subscription
  /// can be told from a leaked one through `hasListener`.
  late List<StreamController<LocationFix>> streams;
  late List<Completer<String?>> nameLookups;
  late List<Map<String, dynamic>> attributeSaves;
  late List<Completer<void>> heldSaves;

  /// While set, every save is left in flight until the test releases it, which
  /// is the window a stop/pause/resume has to race.
  late bool holdSaves;

  setUpAll(() {
    registerFallbackValue(const LocationStreamSettings());
    registerFallbackValue(target);
  });

  Future<void> nextSave() {
    if (!holdSaves) {
      return Future<void>.value();
    }
    final held = Completer<void>();
    heldSaves.add(held);
    return held.future;
  }

  setUp(() {
    locationService = MockLocationService();
    remote = MockLiveTrackingRemote();
    nameResolver = MockEntityNameResolver();
    notifications = MockLiveTrackingNotifications();
    store = InMemoryStore();
    streams = [];
    nameLookups = [];
    attributeSaves = [];
    heldSaves = [];
    holdSaves = false;

    when(() => notifications.clear()).thenAnswer((_) async {});
    when(
      () => notifications.showPaused(targetName: any(named: 'targetName')),
    ).thenAnswer((_) async {});

    when(() => nameResolver.resolveName(any(), any())).thenAnswer((_) {
      final lookup = Completer<String?>();
      nameLookups.add(lookup);
      return lookup.future;
    });

    when(
      () => locationService.positionStream(settings: any(named: 'settings')),
    ).thenAnswer((_) {
      final controller = StreamController<LocationFix>();
      streams.add(controller);
      return controller.stream;
    });

    when(() => remote.saveAttributes(any(), any())).thenAnswer((invocation) {
      attributeSaves.add(
        Map<String, dynamic>.from(
          invocation.positionalArguments[1] as Map<String, dynamic>,
        ),
      );
      return nextSave();
    });
    when(
      () => remote.saveTelemetry(any(), any(), any()),
    ).thenAnswer((_) => nextSave());
  });

  LiveLocationTrackingService buildService() => LiveLocationTrackingService(
    locationService: locationService,
    remote: remote,
    logger: MockTbLogger(),
    store: store,
    nameResolver: nameResolver,
    notifications: notifications,
  );

  Future<LiveLocationTrackingService> startedService() async {
    final service = buildService();
    await service.start(trackingConfig());
    return service;
  }

  /// Lets the oldest in-flight save land, then drains whatever it unblocks.
  Future<void> releaseSaves() async {
    holdSaves = false;
    while (heldSaves.isNotEmpty) {
      heldSaves.removeAt(0).complete();
      await pumpEventQueue();
    }
  }

  /// The `gpsActive` value of each status write, in the order it was sent.
  List<Object?> gpsActiveWrites() =>
      attributeSaves
          .where((save) => save.containsKey('gpsActive'))
          .map((save) => save['gpsActive'])
          .toList();

  group('LiveLocationTrackingService.start', () {
    test('does not subscribe when the session is paused mid-start', () async {
      holdSaves = true;
      final service = buildService();

      final starting = service.start(trackingConfig());
      await pumpEventQueue();
      final pausing = service.pause();
      await pumpEventQueue();

      expect(service.session?.status, LiveTrackingStatus.paused);
      await releaseSaves();
      await starting;
      await pausing;

      expect(
        streams,
        isEmpty,
        reason: 'a session the user paused must not start a GPS stream',
      );
    });

    test('leaves one subscription when a mid-start pause is resumed', () async {
      holdSaves = true;
      final service = buildService();
      final starting = service.start(trackingConfig());
      await pumpEventQueue();
      final pausing = service.pause();
      await pumpEventQueue();
      await releaseSaves();
      await starting;
      await pausing;

      await service.resume();

      expect(streams, hasLength(1));
      expect(
        streams.single.hasListener,
        isTrue,
        reason: 'resume owns the only live stream',
      );
    });

    test('does not subscribe when the session is stopped mid-start', () async {
      holdSaves = true;
      final service = buildService();

      final starting = service.start(trackingConfig());
      await pumpEventQueue();
      final stopping = service.stop();
      await pumpEventQueue();
      await releaseSaves();
      await starting;
      await stopping;

      expect(service.session, isNull);
      expect(
        streams,
        isEmpty,
        reason: 'a stopped session leaves nothing to cancel the stream',
      );
    });
  });

  group('LiveLocationTrackingService gpsActive writes', () {
    test('are applied in the order the transitions happened', () async {
      final service = await startedService();
      await service.pause();
      attributeSaves.clear();

      holdSaves = true;
      final resuming = service.resume();
      await pumpEventQueue();
      expect(attributeSaves, hasLength(1), reason: 'the resume write is out');

      final stopping = service.stop();
      await pumpEventQueue();
      expect(
        attributeSaves,
        hasLength(1),
        reason: 'the stop write waits its turn instead of racing',
      );

      await releaseSaves();
      await resuming;
      await stopping;

      expect(gpsActiveWrites(), [true, false]);
      expect(service.session, isNull);
    });

    test('end with false after a logout teardown', () async {
      final service = await startedService();

      await service.teardownForLogout();

      expect(gpsActiveWrites(), [true, false]);
      expect(service.session, isNull);
      expect(store.record, isNull);
      expect(streams.single.hasListener, isFalse);
    });
  });

  group('LiveLocationTrackingService last record', () {
    test('keeps the finalized session when the name resolves late', () async {
      final service = await startedService();
      streams.single.add(fixAt(10, 20));
      await pumpEventQueue();
      await service.stop();

      nameLookups.single.complete('Thermostat');
      await pumpEventQueue();

      final record = store.record!;
      expect(record.targetName, 'Thermostat');
      expect(record.endedAt, isNotNull);
      expect(record.endReason, TrackingEndReason.manual);
      expect(record.fixCount, 1);
      expect(record.savedCount, 1);
    });

    test('drops a name that resolves for an earlier session', () async {
      final service = buildService();
      await service.start(trackingConfig());
      await service.stop();
      await service.start(trackingConfig());
      final currentStartedAt = service.session!.startedAt;

      nameLookups.first.complete('Thermostat');
      await pumpEventQueue();

      expect(store.record!.startedAt, currentStartedAt);
      expect(store.record!.targetName, isNull);
    });
  });
}
