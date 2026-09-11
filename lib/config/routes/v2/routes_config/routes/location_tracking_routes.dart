import 'package:go_router/go_router.dart';
import 'package:thingsboard_app/modules/location_tracking/presentation/view/live_tracking_page.dart';

class LocationTrackingRoutes {
  static const liveTracking = '/liveTracking';
}

final List<GoRoute> locationTrackingRoutes = [
  GoRoute(
    path: LocationTrackingRoutes.liveTracking,
    builder: (context, state) {
      return const LiveTrackingPage();
    },
  ),
];
