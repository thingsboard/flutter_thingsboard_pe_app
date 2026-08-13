import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/core/auth/login/provider/oauth_provider.dart';
import 'package:thingsboard_app/core/auth/noauth/data/model/switch_endpoint_args.dart';

import 'package:thingsboard_app/core/logger/tb_logger.dart';
import 'package:thingsboard_app/firebase_options.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/endpoint/i_endpoint_service.dart';
import 'package:thingsboard_app/utils/services/firebase/i_firebase_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';
part 'noauth_provider.g.dart';

final class SwitchEndpointParams {
  const SwitchEndpointParams({required this.data});

  final SwitchEndpointArgs data;
}

@riverpod
class NoauthProvider extends _$NoauthProvider {
  final _logger = getIt<TbLogger>();
  @override
  NoAuthState build() {
    return NoAuthState(error: null, isDone: false, message: '');
  }

  Future<void> switchEndpoint(SwitchEndpointParams params) async {
    final uri = params.data.uri;
    final key = params.data.secret;
    final currentEndpoint = await getIt<IEndpointService>().getEndpoint();
    try {
      final host =
          params.data.host ?? (uri.isAbsolute ? uri.origin : currentEndpoint);
      final isTheSameHost =
          Uri.parse(host).host.compareTo(Uri.parse(currentEndpoint).host) == 0;
      _logger.debug(
        'SwitchEndpointUseCase: host=$host currentEndpoint=$currentEndpoint '
        'isTheSameHost=$isTheSameHost hasSecret=${key != null}',
      );

      if (key == null || key.isEmpty) {
        // A QR link without a secret (e.g. the mobile app QR shown on the
        // login page) cannot log the user in: just switch to the target host
        // and let the login page of that host take over.
        await _switchHostOnly(
          host: host,
          currentEndpoint: currentEndpoint,
          isTheSameHost: isTheSameHost,
        );
        return;
      }

      state = NoAuthState(
        error: null,
        isDone: false,
        message: 'Getting data from your host $host',
      );

      // Fetch JWT pair using secret key from the TARGET host via the QR code
      // API. A raw Dio is used (instead of the typed
      // `getQrCodeSettingsControllerApi().getUserTokenByMobileSecret`) because
      // the request must hit `host`, not the current client's endpoint.
      final tempDio = Dio(
        BaseOptions(
          baseUrl: host,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );
      final Response<dynamic> secretResponse;
      try {
        secretResponse = await tempDio.get('/api/noauth/qr/$key');
      } on DioException catch (e) {
        // The server replies with a ThingsboardError body (e.g. an expired
        // one-time secret): surface its message instead of the raw Dio text.
        final body = e.response?.data;
        final serverMessage = body is Map ? body['message'] as String? : null;
        throw ThingsboardError(
          message:
              serverMessage ??
              'Failed to obtain a login token from $host. '
                  'Please scan a new QR code.',
          status: e.response?.statusCode,
        );
      }
      final data = secretResponse.data;
      final tokenStr = data is Map ? data['token'] as String? : null;
      final refreshTokenStr =
          data is Map ? data['refreshToken'] as String? : null;
      if (tokenStr == null) {
        throw ThingsboardError(
          message: 'Failed to obtain a login token from $host',
        );
      }

      // The server can hand out an already-revoked pair: the pair is bound
      // to the QR secret, so re-scanning the same code after a logout yields
      // tokens issued before the logout watermark ('Token is outdated').
      // Verify the pair against the target host BEFORE switching, otherwise
      // the new client would enter a login/refresh loop it can never win.
      try {
        await tempDio.get(
          '/api/auth/user',
          options: Options(headers: {'X-Authorization': 'Bearer $tokenStr'}),
        );
      } on DioException catch (e) {
        final body = e.response?.data;
        final serverMessage = body is Map ? body['message'] as String? : null;
        throw ThingsboardError(
          message:
              serverMessage ??
              'The QR code session is no longer valid. '
                  'Please refresh the QR code and scan again.',
          status: e.response?.statusCode,
        );
      }

      if (isTheSameHost) {
        state = NoAuthState(
          error: null,
          isDone: false,
          message: 'Logging you into the host $host',
        );
      } else {
        state = NoAuthState(
          error: null,
          isDone: false,
          message: 'Switching you to the new host $host',
        );
      }

      // Stage the exchanged JWT pair in storage BEFORE re-creating the
      // client: reInit logs in from storage, so this guarantees the new
      // client starts with exactly these tokens. Never hand them to the old
      // client instance, and never let a session left in storage by a
      // previous host win the race (PROD-8200).
      final storage = getIt<TbStorage>();
      await storage.setItem('jwt_token', tokenStr);
      if (refreshTokenStr != null) {
        await storage.setItem('refresh_token', refreshTokenStr);
      } else {
        await storage.deleteItem('refresh_token');
      }
      await getIt<IEndpointService>().setEndpoint(host);
      if (!isTheSameHost) {
        await _switchFirebaseApps(currentEndpoint);
      }

      await getIt<ITbClientService>().reInit(
        endpoint: host,
        onDone: () => ref.invalidate(oauthProvider),
        onAuthError: (e) {
          // Client-level errors are surfaced by the client service itself;
          // throwing here would escape the callback as an unhandled zone
          // error and leak a raw stacktrace to the UI (PROD-8200).
          _logger.error('SwitchEndpointUseCase:onAuthError $e');
        },
      );
      if (!getIt<ITbClientService>().client.isAuthenticated()) {
        // The staged tokens were lost before init picked them up (e.g. a
        // failing background refresh of the previous session cleared the
        // shared storage in the meantime): apply the exchanged pair to the
        // new client directly.
        _logger.debug('SwitchEndpointUseCase: re-applying exchanged tokens');
        await getIt<ITbClientService>().client.setUserFromJwtToken(
          tokenStr,
          refreshTokenStr,
          true,
        );
      }
      _logger.debug('SwitchEndpointUseCase: switch to $host done');
      state = NoAuthState(error: null, isDone: true, message: '');
    } catch (e) {
      _logger.error('SwitchEndpointUseCase:catch $e', e);
      await reset(previousEndpoint: currentEndpoint);
      state = NoAuthState(
        error: e,
        isDone: false,
        message: e is ThingsboardError ? e.message ?? e.toString() : '$e',
      );
    }
  }

  Future<void> _switchHostOnly({
    required String host,
    required String currentEndpoint,
    required bool isTheSameHost,
  }) async {
    if (!isTheSameHost) {
      state = NoAuthState(
        error: null,
        isDone: false,
        message: 'Switching you to the new host $host',
      );
      // A host switch without a login secret ends on the login page of the
      // new host: the previous host's session tokens are meaningless there.
      await getIt<ITbClientService>().client.setUserFromJwtToken(
        null,
        null,
        false,
      );
      await getIt<IEndpointService>().setEndpoint(host);
      await _switchFirebaseApps(currentEndpoint);
      await getIt<ITbClientService>().reInit(
        endpoint: host,
        onDone: () => ref.invalidate(oauthProvider),
        onAuthError: (e) {
          _logger.error('SwitchEndpointUseCase:onAuthError $e');
        },
      );
    }
    state = NoAuthState(error: null, isDone: true, message: '');
  }

  Future<void> _switchFirebaseApps(String previousEndpoint) async {
    _logger.debug('SwitchEndpointUseCase:deleteFB App');
    if (Firebase.apps.isNotEmpty) {
      getIt<IFirebaseService>()
        ..removeApp()
        ..removeApp(name: previousEndpoint);
    }

    // If we revert to the original host configured in the app_constants
    final isCustom = await getIt<IEndpointService>().isCustomEndpoint();
    if (!isCustom) {
      await _initDefaultFbApp();
    }
  }

  Future<void> _initDefaultFbApp() async {
    try {
      await getIt<IFirebaseService>().initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      //Ignore this error if fcm is not configured
      if (e is! UnsupportedError) {
        rethrow;
      }
    }
  }

  /// Rolls the app back to the endpoint that was active before the failed
  /// switch. The previous session tokens are still in storage (the new ones
  /// are only persisted after a successful reInit), so a logged-in user keeps
  /// their session.
  Future<void> reset({required String previousEndpoint}) async {
    try {
      await getIt<IEndpointService>().setEndpoint(previousEndpoint);
      await getIt<IFirebaseService>().clearApps();
      final isCustom = await getIt<IEndpointService>().isCustomEndpoint();
      if (!isCustom) {
        await _initDefaultFbApp();
      }
      await getIt<ITbClientService>().reInit(
        endpoint: previousEndpoint,
        onDone: () => ref.invalidate(oauthProvider),
        onAuthError: (e) {
          _logger.error('SwitchEndpointUseCaseReset:onAuthError $e');
        },
      );
    } catch (e) {
      _logger.error('SwitchEndpointUseCaseReset:onError $e');
    }
  }
}

class NoAuthState {
  NoAuthState({
    required this.error,
    required this.isDone,
    required this.message,
  });
  final dynamic error;
  final bool isDone;
  final String message;
}
