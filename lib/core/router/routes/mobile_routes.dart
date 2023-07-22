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
        TypedGoRoute<ProfilesRoute>(path: ProfilesRoute.path),
        TypedGoRoute<NewProfileRoute>(path: NewProfileRoute.path),
        TypedGoRoute<ProfileDetailsRoute>(path: ProfileDetailsRoute.path),
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

@TypedGoRoute<LogsRoute>(path: LogsRoute.path)
class LogsRoute extends GoRouteData {
  const LogsRoute();
  static const path = '/logs';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: LogsPage(),
    );
  }
}

@TypedGoRoute<SettingsRoute>(path: SettingsRoute.path)
class SettingsRoute extends GoRouteData {
  const SettingsRoute();
  static const path = '/settings';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: SettingsPage(),
    );
  }
}

@TypedGoRoute<AboutRoute>(path: AboutRoute.path)
class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const path = '/about';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: AboutPage(),
    );
  }
}
