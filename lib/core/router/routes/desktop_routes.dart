import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/routes/shared_routes.dart';
import 'package:hiddify/features/about/view/view.dart';
import 'package:hiddify/features/logs/view/view.dart';
import 'package:hiddify/features/settings/view/view.dart';
import 'package:hiddify/features/wrapper/wrapper.dart';

part 'desktop_routes.g.dart';

@TypedShellRoute<DesktopWrapperRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(
      path: HomeRoute.path,
      routes: [
        TypedGoRoute<AddProfileRoute>(path: AddProfileRoute.path),
        TypedGoRoute<ProfilesRoute>(path: ProfilesRoute.path),
        TypedGoRoute<NewProfileRoute>(path: NewProfileRoute.path),
        TypedGoRoute<ProfileDetailsRoute>(path: ProfileDetailsRoute.path),
      ],
    ),
    TypedGoRoute<ProxiesRoute>(path: ProxiesRoute.path),
    TypedGoRoute<LogsRoute>(path: LogsRoute.path),
    TypedGoRoute<SettingsRoute>(
      path: SettingsRoute.path,
      routes: [
        TypedGoRoute<ConfigOptionsRoute>(path: ConfigOptionsRoute.path),
      ],
    ),
    TypedGoRoute<AboutRoute>(path: AboutRoute.path),
  ],
)
class DesktopWrapperRoute extends ShellRouteData {
  const DesktopWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return DesktopWrapper(navigator);
  }
}

class LogsRoute extends GoRouteData {
  const LogsRoute();
  static const path = '/logs';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: LogsPage());
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const path = '/settings';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: SettingsPage());
  }
}

class ConfigOptionsRoute extends GoRouteData {
  const ConfigOptionsRoute();
  static const path = 'config-options';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: ConfigOptionsPage(),
    );
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const path = '/about';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: AboutPage());
  }
}
