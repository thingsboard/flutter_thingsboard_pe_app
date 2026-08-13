import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:thingsboard_app/core/auth/login/provider/login_provider.dart';
import 'package:thingsboard_app/core/auth/noauth/data/model/switch_endpoint_args.dart';
import 'package:thingsboard_app/core/auth/noauth/presentation/widgets/noauth_loading_widget.dart';
import 'package:thingsboard_app/core/auth/noauth/provider/noauth_provider.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/main/providers/navigation_provider.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

class SwitchEndpointNoAuthView extends HookConsumerWidget {
  const SwitchEndpointNoAuthView({required this.arguments, super.key});
  final SwitchEndpointArgs? arguments;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noAuth = ref.watch(noauthProviderProvider);
    useEffect(() {
      ref.invalidate(noauthProviderProvider);
      if (arguments != null) {
        ref
            .read(noauthProviderProvider.notifier)
            .switchEndpoint(SwitchEndpointParams(data: arguments!));
      } else {
        // Nothing to switch to: never leave the user on an endless spinner.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/login');
          }
        });
      }
      return null;
    }, []);
    ref.listen(noauthProviderProvider, (prev, next) {
      if (next.error != null) {
        Future.delayed(const Duration(seconds: 5), () {
          if (!context.mounted) {
            return;
          }
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        });
      }
      if (next.isDone) {
        // A switch with a login secret ends authenticated: HomeHandler
        // navigates to the home page once the user is fully loaded. A
        // host-only switch (QR without a secret) ends unauthenticated: show
        // the login page of the new host.
        final authenticated =
            getIt<ITbClientService>().client.isAuthenticated();
        if (!context.mounted) {
          return;
        }
        if (!authenticated) {
          context.go('/login');
        } else if (ref.read(loginProvider).isFullyAuthenticated()) {
          // Already fully logged in (e.g. the same QR was scanned twice):
          // HomeHandler won't see a state transition, navigate ourselves.
          final navigation = ref.read(navigationProvider);
          if (navigation.bottomBarPages.isNotEmpty) {
            context.go(navigation.bottomBarPages.first.path);
          }
        } else {
          // HomeHandler navigates once the user finishes loading. If that
          // never happens (e.g. the new session gets rejected), don't leave
          // the user on the spinner forever.
          Future.delayed(const Duration(seconds: 12), () {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      }
    });
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (noAuth.error != null) {
              final error = noAuth.error;
              // Never render error.toString(): for ThingsboardError it
              // includes the captured stacktrace (PROD-8200).
              final message =
                  error is ThingsboardError
                      ? error.message ?? noAuth.message
                      : noAuth.message;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const NoAuthLoadingWidget(),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 + 80,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            noAuth.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
