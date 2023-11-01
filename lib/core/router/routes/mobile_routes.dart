import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/core/router/routes/shared_routes.dart';
import 'package:hiddify/features/about/view/view.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/features/logs/view/view.dart';
import 'package:hiddify/features/settings/view/view.dart';

part 'mobile_routes.g.dart';

@TypedShellRoute<MobileWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: HomeRoute.path,
      name: HomeRoute.name,
      routes: [
        TypedGoRoute<AddProfileRoute>(
          path: AddProfileRoute.path,
          name: AddProfileRoute.name,
        ),
        TypedGoRoute<ProfilesRoute>(
          path: ProfilesRoute.path,
          name: ProfilesRoute.name,
        ),
        TypedGoRoute<NewProfileRoute>(
          path: NewProfileRoute.path,
          name: NewProfileRoute.name,
        ),
        TypedGoRoute<ProfileDetailsRoute>(
          path: ProfileDetailsRoute.path,
          name: ProfileDetailsRoute.name,
        ),
        TypedGoRoute<LogsRoute>(
          path: LogsRoute.path,
          name: LogsRoute.name,
        ),
        TypedGoRoute<SettingsRoute>(
          path: SettingsRoute.path,
          name: SettingsRoute.name,
          routes: [
            TypedGoRoute<ConfigOptionsRoute>(
              path: ConfigOptionsRoute.path,
              name: ConfigOptionsRoute.name,
            ),
            TypedGoRoute<PerAppProxyRoute>(
              path: PerAppProxyRoute.path,
              name: PerAppProxyRoute.name,
            ),
          ],
        ),
        TypedGoRoute<AboutRoute>(
          path: AboutRoute.path,
          name: AboutRoute.name,
        ),
      ],
    ),
    TypedGoRoute<ProxiesRoute>(
      path: ProxiesRoute.path,
      name: ProxiesRoute.name,
    ),
  ],
)
class MobileWrapperRoute extends ShellRouteData {
  const MobileWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

class LogsRoute extends GoRouteData {
  const LogsRoute();
  static const path = 'logs';
  static const name = 'Logs';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: LogsPage(),
    );
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const path = 'settings';
  static const name = 'Settings';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: SettingsPage(),
    );
  }
}

class ConfigOptionsRoute extends GoRouteData {
  const ConfigOptionsRoute();
  static const path = 'config-options';
  static const name = 'Config Options';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ConfigOptionsPage(),
    );
  }
}

class PerAppProxyRoute extends GoRouteData {
  const PerAppProxyRoute();
  static const path = 'per-app-proxy';
  static const name = 'Per-app Proxy';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: PerAppProxyPage(),
    );
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const path = 'about';
  static const name = 'About';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: AboutPage(),
    );
  }
}
