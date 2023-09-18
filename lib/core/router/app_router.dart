import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/core/router/routes/routes.dart';
import 'package:hiddify/services/deep_link_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'app_router.g.dart';

// TODO: test and improve handling of deep link
@riverpod
GoRouter router(RouterRef ref) {
  final introCompleted = ref.watch(introCompletedProvider);
  final deepLink = ref.listen(
    deepLinkServiceProvider,
    (_, next) async {
      if (next case AsyncData(value: final link?)) {
        await ref.state.push(AddProfileRoute(url: link.url).location);
      }
    },
  );
  final initialLink = deepLink.read();
  String initialLocation = const HomeRoute().location;
  if (initialLink case AsyncData(value: final link?)) {
    initialLocation = AddProfileRoute(url: link.url).location;
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    routes: $routes,
    observers: [
      SentryNavigatorObserver(),
    ],
    redirect: (context, state) {
      if (!introCompleted && state.uri.path != const IntroRoute().location) {
        return const IntroRoute().location;
      }
      return null;
    },
  );
}

int getCurrentIndex(BuildContext context) {
  final String location = GoRouterState.of(context).uri.path;
  if (location == const HomeRoute().location) return 0;
  if (location.startsWith(const ProxiesRoute().location)) return 1;
  if (location.startsWith(const LogsRoute().location)) return 2;
  if (location.startsWith(const SettingsRoute().location)) return 3;
  if (location.startsWith(const AboutRoute().location)) return 4;
  return 0;
}

void switchTab(int index, BuildContext context) {
  switch (index) {
    case 0:
      const HomeRoute().go(context);
    case 1:
      const ProxiesRoute().go(context);
    case 2:
      const LogsRoute().go(context);
    case 3:
      const SettingsRoute().go(context);
    case 4:
      const AboutRoute().go(context);
  }
}
