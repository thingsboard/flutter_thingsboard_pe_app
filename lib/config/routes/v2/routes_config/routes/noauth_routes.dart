import 'package:go_router/go_router.dart';
import 'package:thingsboard_app/core/auth/noauth/data/model/switch_endpoint_args.dart';
import 'package:thingsboard_app/core/auth/noauth/presentation/view/switch_endpoint_noauth_view.dart';

const noAuthPath = '/api/noauth/qr';
// NoAuth routes
final List<GoRoute> noAuthRoutes = [
  GoRoute(
    path: noAuthPath,
    builder: (context, state) {
      // A link without a secret (e.g. the app QR from the login page) is
      // still a valid host switch, so parse arguments in both cases. The
      // original scanned link is passed along as the `uri` parameter.
      final params = {
        ...state.uri.queryParameters,
        'uri': state.uri.queryParameters['uri'] ?? state.uri.toString(),
      };
      final args = SwitchEndpointArgs.fromJson(params);

      return SwitchEndpointNoAuthView(arguments: args);
    },
  ),
];
