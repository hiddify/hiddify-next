import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/routes/shared_routes.dart';
import 'package:hiddify/features/about/view/view.dart';
import 'package:hiddify/features/logs/view/view.dart';
import 'package:hiddify/features/settings/view/view.dart';
import 'package:hiddify/features/wrapper/wrapper.dart';

part 'mobile_routes.g.dart';

@TypedShellRoute<MobileWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: HomeRoute.path,
      routes: [
        TypedGoRoute<AddProfileRoute>(path: AddProfileRoute.path),
        TypedGoRoute<ProfilesRoute>(path: ProfilesRoute.path),
        TypedGoRoute<NewProfileRoute>(path: NewProfileRoute.path),
        TypedGoRoute<ProfileDetailsRoute>(path: ProfileDetailsRoute.path),
        TypedGoRoute<LogsRoute>(path: LogsRoute.path),
        TypedGoRoute<SettingsRoute>(
          path: SettingsRoute.path,
          routes: [
            TypedGoRoute<ConfigOptionsRoute>(path: ConfigOptionsRoute.path),
            TypedGoRoute<PerAppProxyRoute>(path: PerAppProxyRoute.path),
          ],
        ),
        TypedGoRoute<AboutRoute>(path: AboutRoute.path),
      ],
    ),
    TypedGoRoute<ProxiesRoute>(path: ProxiesRoute.path),
  ],
)
class MobileWrapperRoute extends ShellRouteData {
  const MobileWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MobileWrapper(navigator);
  }
}

class LogsRoute extends GoRouteData {
  const LogsRoute();
  static const path = 'logs';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: LogsPage(),
    );
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const path = 'settings';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: SettingsPage(),
    );
  }
}

class ConfigOptionsRoute extends GoRouteData {
  const ConfigOptionsRoute();
  static const path = 'config-options';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: ConfigOptionsPage(),
    );
  }
}

class PerAppProxyRoute extends GoRouteData {
  const PerAppProxyRoute();
  static const path = 'per-app-proxy';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: PerAppProxyPage(),
    );
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const path = 'about';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: AboutPage(),
    );
  }
}
