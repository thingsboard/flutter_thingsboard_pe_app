import 'dart:convert';

import 'package:thingsboard_app/constants/app_constants.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_remote.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/model/live_tracking_config.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

class LiveTrackingRemote implements ILiveTrackingRemote {
  LiveTrackingRemote({required ITbClientService clientService})
    : _clientService = clientService;

  final ITbClientService _clientService;

  @override
  Future<void> saveTelemetry(
    LiveTrackingTarget target,
    int ts,
    Map<String, dynamic> values,
  ) async {
    await _clientService.client.getTelemetryControllerApi().saveEntityTelemetry(
      entityType: target.entityType,
      entityId: target.id,
      scope: 'ANY',
      body: jsonEncode({'ts': ts, 'values': values}),
      extra: ThingsboardAppConstants.backgroundRequest,
    );
  }

  @override
  Future<void> saveAttributes(
    LiveTrackingTarget target,
    Map<String, dynamic> attributes,
  ) async {
    await _clientService.client
        .getTelemetryControllerApi()
        .saveEntityAttributesV2(
          entityType: target.entityType,
          entityId: target.id,
          scope: 'SERVER_SCOPE',
          body: jsonEncode(attributes),
          extra: ThingsboardAppConstants.backgroundRequest,
        );
  }
}
