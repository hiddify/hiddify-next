import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/routes/shared_routes.dart';
import 'package:hiddify/features/about/view/view.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/features/logs/view/view.dart';
import 'package:hiddify/features/settings/view/view.dart';

part 'desktop_routes.g.dart';

@TypedShellRoute<DesktopWrapperRoute>(
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
      ],
    ),
    TypedGoRoute<ProxiesRoute>(
      path: ProxiesRoute.path,
      name: ProxiesRoute.name,
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
      ],
    ),
    TypedGoRoute<AboutRoute>(
      path: AboutRoute.path,
      name: AboutRoute.name,
    ),
  ],
)
class DesktopWrapperRoute extends ShellRouteData {
  const DesktopWrapperRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return AdaptiveRootScaffold(navigator);
  }
}

class LogsRoute extends GoRouteData {
  const LogsRoute();
  static const path = '/logs';
  static const name = 'Logs';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(name: name, child: LogsPage());
  }
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const path = '/settings';
  static const name = 'Settings';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(name: name, child: SettingsPage());
  }
}

class ConfigOptionsRoute extends GoRouteData {
  const ConfigOptionsRoute();
  static const path = 'config-options';
  static const name = 'Config Options';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ConfigOptionsPage(),
    );
  }
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const path = '/about';
  static const name = 'About';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: AboutPage(),
    );
  }
}
