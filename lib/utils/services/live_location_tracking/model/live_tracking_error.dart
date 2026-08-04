import 'package:thingsboard_app/thingsboard_client.dart';

/// Why the session is degraded, as a cause the UI layer can localize.
/// Raw exception text (stack traces, URLs, Angular/Dio wording) must never
/// reach the session screen — details go to the logger only.
enum LiveTrackingError {
  targetNotFound,
  noConnection,
  unauthorized,
  saveFailed,
  locationServicesDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  locationError;

  /// Classifies a failed save. A deleted target arrives with an empty server
  /// message (`[404: ]`), so causes are derived from status/error code —
  /// server text is never passed through.
  static LiveTrackingError fromSaveException(Object e) {
    final error = toThingsboardError(e);
    if (error.errorCode == ThingsBoardErrorCode.general &&
        error.message == 'Unable to connect') {
      return noConnection;
    }
    // The interceptor reports a missing token as a bare 'Unauthorized!'
    // message with no status or error code.
    if (error.status == 401 ||
        error.message == 'Unauthorized!' ||
        error.errorCode == ThingsBoardErrorCode.authentication ||
        error.errorCode == ThingsBoardErrorCode.jwtTokenExpired) {
      return unauthorized;
    }
    if (error.status == 404 ||
        error.errorCode == ThingsBoardErrorCode.itemNotFound) {
      return targetNotFound;
    }
    return saveFailed;
  }
}
