import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final localizations = MaterialLocalizations.of(context);
      return AlertDialog(
        icon: const Icon(FluentIcons.delete_24_regular),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(localizations.okButtonLabel),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(localizations.cancelButtonLabel),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
