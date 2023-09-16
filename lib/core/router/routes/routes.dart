import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/routes/desktop_routes.dart' as desktop;
import 'package:hiddify/core/router/routes/mobile_routes.dart' as mobile;
import 'package:hiddify/core/router/routes/shared_routes.dart' as shared;
import 'package:hiddify/utils/utils.dart';

export 'mobile_routes.dart';
export 'shared_routes.dart' hide $appRoutes;

List<RouteBase> get $routes => [
      ...shared.$appRoutes,
      if (PlatformUtils.isDesktop)
        ...desktop.$appRoutes
      else
        ...mobile.$appRoutes,
    ];
