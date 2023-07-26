import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/home/view/view.dart';
import 'package:hiddify/features/profile_detail/view/view.dart';
import 'package:hiddify/features/profiles/view/view.dart';
import 'package:hiddify/features/proxies/view/view.dart';
import 'package:hiddify/features/settings/view/view.dart';
import 'package:hiddify/utils/utils.dart';

part 'shared_routes.g.dart';

List<RouteBase> get $sharedRoutes => $appRoutes;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class HomeRoute extends GoRouteData {
  const HomeRoute();
  static const path = '/';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: HomePage());
  }
}

class ProxiesRoute extends GoRouteData {
  const ProxiesRoute();
  static const path = '/proxies';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(child: ProxiesPage());
  }
}

@TypedGoRoute<AddProfileRoute>(path: AddProfileRoute.path)
class AddProfileRoute extends GoRouteData {
  const AddProfileRoute({this.url});
  static const path = '/add';
  final String? url;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      fixed: true,
      builder: (controller) => AddProfileModal(
        url: url,
        scrollController: controller,
      ),
    );
  }
}

class ProfilesRoute extends GoRouteData {
  const ProfilesRoute();
  static const path = 'profiles';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return BottomSheetPage(
      builder: (controller) => ProfilesModal(scrollController: controller),
    );
  }
}

class NewProfileRoute extends GoRouteData {
  const NewProfileRoute({this.url, this.name});
  static const path = 'profiles/new';
  final String? url;
  final String? name;

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      child: ProfileDetailPage(
        "new",
        url: url,
        name: name,
      ),
    );
  }
}

class ProfileDetailsRoute extends GoRouteData {
  const ProfileDetailsRoute(this.id);
  final String id;
  static const path = 'profiles/:id';

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage(
      fullscreenDialog: true,
      child: ProfileDetailPage(id),
    );
  }
}

class ClashOverridesRoute extends GoRouteData {
  const ClashOverridesRoute();
  static const path = 'clash-overrides';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const MaterialPage(
      fullscreenDialog: true,
      child: ClashOverridesPage(),
    );
  }
}
