import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action_result.dart';

class LaunchResult extends MobileActionResult {
  LaunchResult(this.launched, {this.trackingInfo});
  bool launched;

  /// Live tracking session details ({targetName, keys}) attached to
  /// start/stop live location acks so the dashboard can show what is being
  /// saved and where.
  Map<String, dynamic>? trackingInfo;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['launched'] = launched;
    if (trackingInfo != null) {
      json['trackingInfo'] = trackingInfo;
    }
    return json;
  }
}
