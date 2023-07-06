import 'package:flutter/material.dart';

abstract class RootScaffold {
  static final stateKey = GlobalKey<ScaffoldState>();
}

class NestedTabAppBar extends SliverAppBar {
  NestedTabAppBar({
    super.key,
    super.title,
    super.actions,
    super.pinned = true,
    super.forceElevated,
    super.bottom,
  }) : super(
          leading: RootScaffold.stateKey.currentState?.hasDrawer ?? false
              ? DrawerButton(
                  onPressed: () {
                    RootScaffold.stateKey.currentState?.openDrawer();
                  },
                )
              : null,
        );
}
