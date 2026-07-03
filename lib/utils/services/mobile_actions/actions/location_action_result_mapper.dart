import 'package:thingsboard_app/utils/services/location/model/location_fix.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action_result.dart';
import 'package:thingsboard_app/utils/services/mobile_actions/widget_mobile_action_result.dart';

/// Shared mapping of a [LocationFix] to a [WidgetMobileActionResult], used by
/// both the one-shot `GetLocationAction` and the live `GetLiveLocationAction`
/// so the success/failure result contract stays identical between them.
mixin LocationActionResultMapper {
  WidgetMobileActionResult mapLocationFixToResult(LocationFix fix) {
    return switch (fix) {
      LocationSuccess(:final position) =>
        WidgetMobileActionResult.successResult(
          MobileActionResult.location(position.latitude, position.longitude),
        ),
      LocationServicesDisabled() => WidgetMobileActionResult.errorResult(
        'Location services are disabled.',
      ),
      LocationPermissionDenied() => WidgetMobileActionResult.errorResult(
        'Location permissions are denied.',
      ),
      LocationPermissionDeniedForever() => WidgetMobileActionResult.errorResult(
        'Location permissions are permanently denied, we cannot request permissions.',
      ),
      LocationFixError(:final message) => WidgetMobileActionResult.errorResult(
        message,
      ),
    };
  }
}
