import 'package:thingsboard_app/utils/services/mobile_actions/mobile_action_result.dart';

class LocationResult extends MobileActionResult {
  LocationResult(this.latitude, this.longitude, {this.accuracy, this.ts});
  num latitude;
  num longitude;
  num? accuracy;
  int? ts;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['latitude'] = latitude;
    json['longitude'] = longitude;
    if (accuracy != null) {
      json['accuracy'] = accuracy;
    }
    if (ts != null) {
      json['ts'] = ts;
    }
    return json;
  }
}
