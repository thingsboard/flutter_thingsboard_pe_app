import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:thingsboard_app/config/routes/v2/router_2.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/location/i_location_service.dart';
import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/actions/location_action_result_mapper.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/widget_mobile_action_result.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/widget_mobile_action_type.dart';

/// Live counterpart of [WidgetMobileActionType.getLocation]: subscribes to
/// [ILocationService.positionStream] and reflects the device position as it
/// updates, rather than returning a single fix.
///
/// NOTE: the dialog below is a placeholder visualization used to exercise the
/// live stream — the production UI is not decided yet. The action is registered
/// under [WidgetMobileActionType.getLiveLocation] but is not yet triggered by
/// any dashboard widget.
class GetLiveLocationAction extends MobileAction
    with LocationActionResultMapper {
  @override
  Future<WidgetMobileActionResult> execute(
    List args,
    InAppWebViewController controller,
  ) async {
    try {
      final service = getIt<ILocationService>();
      final context = globalNavigatorKey.currentContext!;

      // Most recent successful fix, handed back when the dialog is dismissed.
      LocationFix? lastFix;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Live location'),
            content: StreamBuilder<LocationFix>(
              stream: service.positionStream(),
              builder: (ctx, snapshot) {
                final fix = snapshot.data;
                if (fix is LocationSuccess) {
                  lastFix = fix;
                }
                return Text(_describe(fix));
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );

      return lastFix == null
          ? WidgetMobileActionResult.emptyResult()
          : mapLocationFixToResult(lastFix!);
    } catch (e) {
      return handleError(e);
    }
  }

  String _describe(LocationFix? fix) => switch (fix) {
    null => 'Waiting for first GPS fix…',
    LocationSuccess(:final position) =>
      'lat: ${position.latitude.toStringAsFixed(6)}\n'
          'lng: ${position.longitude.toStringAsFixed(6)}\n'
          'accuracy: ${position.accuracy.toStringAsFixed(1)} m\n'
          'updated: ${position.timestamp}',
    LocationServicesDisabled() => 'Location services are disabled.',
    LocationPermissionDenied() => 'Location permission denied.',
    LocationPermissionDeniedForever() =>
      'Location permission permanently denied.',
    LocationFixError(:final message) => 'Error: $message',
  };

  @override
  WidgetMobileActionType get type => WidgetMobileActionType.getLiveLocation;
}
