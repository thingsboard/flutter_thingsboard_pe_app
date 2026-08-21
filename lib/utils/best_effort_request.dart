import 'package:thingsboard_app/thingsboard_client.dart';

/// Request extra for calls whose failure the user must not be told about:
/// best-effort calls made right around a login (mobile app info, notification
/// mobile-session sync, unread counts) answer 401/403 in perfectly normal
/// situations, and a toast there reads as a failed login (PROD-8200).
///
/// This suppresses the *notification* only. A 401 with `jwtTokenExpired` still
/// makes the client refresh the token and, if that refresh fails, clear the
/// stored session - see `HttpInterceptor.onError` in the client library.
Map<String, dynamic> bestEffortRequestExtra() =>
    InterceptorConfig(ignoreErrors: true, ignoreLoading: true).toExtra();
