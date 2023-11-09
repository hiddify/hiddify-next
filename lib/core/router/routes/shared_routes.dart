import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/features/home/view/view.dart';
import 'package:hiddify/features/intro/intro_page.dart';
import 'package:hiddify/features/profile_detail/view/view.dart';
import 'package:hiddify/features/profiles/view/view.dart';
import 'package:hiddify/features/proxies/view/view.dart';
import 'package:hiddify/utils/utils.dart';

part 'shared_routes.g.dart';

class HomeRoute extends GoRouteData {
  const HomeRoute();
  static const path = '/';
  static const name = 'Home';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: HomePage(),
    );
  }
}

class ProxiesRoute extends GoRouteData {
  const ProxiesRoute();
  static const path = '/proxies';
  static const name = 'Proxies';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      name: name,
      child: ProxiesPage(),
    );
  }
}

class AddProfileRoute extends GoRouteData {
  const AddProfileRoute({this.url});
  static const path = 'add';
  static const name = 'Add Profile';
  final String? url;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      name: name,
      builder: (controller) => AddProfileModal(
        url: url,
        scrollController: controller,
      ),
    );
  }
}

@TypedGoRoute<IntroRoute>(path: IntroRoute.path, name: IntroRoute.name)
class IntroRoute extends GoRouteData {
  const IntroRoute();
  static const path = '/intro';
  static const name = 'Intro';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: IntroPage(),
    );
  }
}

class ProfilesRoute extends GoRouteData {
  const ProfilesRoute();
  static const path = 'profiles';
  static const name = 'Profiles';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      name: name,
      builder: (controller) => ProfilesModal(scrollController: controller),
    );
  }
}

class NewProfileRoute extends GoRouteData {
  const NewProfileRoute();
  static const path = 'profiles/new';
  static const name = 'New Profile';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailPage("new"),
    );
  }
}

class ProfileDetailsRoute extends GoRouteData {
  const ProfileDetailsRoute(this.id);
  final String id;
  static const path = 'profiles/:id';
  static const name = 'Profile Details';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      name: name,
      child: ProfileDetailPage(id),
    );
  }
}
