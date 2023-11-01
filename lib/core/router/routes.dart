import 'package:hiddify/core/router/routes/desktop_routes.dart' as desktop;
import 'package:hiddify/core/router/routes/mobile_routes.dart' as mobile;
import 'package:hiddify/core/router/routes/shared_routes.dart' as shared;

export 'routes/mobile_routes.dart';
export 'routes/shared_routes.dart' hide $appRoutes;

final mobileRoutes = [
  ...shared.$appRoutes,
  ...mobile.$appRoutes,
];

final desktopRoutes = [
  ...shared.$appRoutes,
  ...desktop.$appRoutes,
];
