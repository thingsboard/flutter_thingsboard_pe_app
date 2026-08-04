import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_location_tracking_service.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/i_live_tracking_store.dart';
import 'package:thingsboard_app/utils/services/live_location_tracking/live_tracking_display.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action_result.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/widget_mobile_action_result.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/widget_mobile_action_type.dart';

class StopLiveLocationAction extends MobileAction {
  @override
  Future<WidgetMobileActionResult> execute(
    List args,
    InAppWebViewController controller,
  ) async {
    try {
      final service = getIt<ILiveLocationTrackingService>();
      final session = service.session;
      if (session == null) {
        return WidgetMobileActionResult.emptyResult();
      }
      final config = session.config;
      final resolvedName =
          config.targetName ??
          (await getIt<ILiveTrackingStore>().read())?.targetName;
      await service.stop();
      return WidgetMobileActionResult.successResult(
        MobileActionResult.launched(
          true,
          trackingInfo: {
            'targetName': displayTargetName(resolvedName, config.target),
            'keys': config.keys.map((key) => key.label).toList(growable: false),
          },
        ),
      );
    } catch (e) {
      return handleError(e);
    }
  }

  @override
  WidgetMobileActionType get type => WidgetMobileActionType.stopLiveLocation;
}
