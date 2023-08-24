import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OptionalSettingsInputDialog<T> extends HookConsumerWidget
    with PresLogger {
  const OptionalSettingsInputDialog({
    super.key,
    required this.title,
    this.initialValue,
    this.resetValue = const None(),
    this.icon,
  });

  final String title;
  final T? initialValue;

  /// default value, useful for mandatory fields
  final Option<T> resetValue;
  final IconData? icon;

  Future<Option<String>?> show(BuildContext context) async {
    return showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final localizations = MaterialLocalizations.of(context);

    final textController = useTextEditingController(
      text: initialValue?.toString(),
    );

    return AlertDialog(
      title: Text(title),
      icon: icon != null ? Icon(icon) : null,
      content: TextFormField(
        controller: textController,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
        ],
        autovalidateMode: AutovalidateMode.always,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Navigator.of(context)
                .maybePop(resetValue.map((t) => t.toString()));
          },
          child: Text(t.general.reset.toUpperCase()),
        ),
        TextButton(
          onPressed: () async {
            await Navigator.of(context).maybePop();
          },
          child: Text(localizations.cancelButtonLabel.toUpperCase()),
        ),
        TextButton(
          onPressed: () async {
            // onConfirm(textController.value.text);
            await Navigator.of(context)
                .maybePop(some(textController.value.text));
          },
          child: Text(localizations.okButtonLabel.toUpperCase()),
        ),
      ],
    );
  }
}

class SettingsInputDialog<T> extends HookConsumerWidget with PresLogger {
  const SettingsInputDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.mapTo,
    this.resetValue,
    this.icon,
    this.digitsOnly = false,
  });

  final String title;
  final T initialValue;
  final T? Function(String value)? mapTo;
  final T? resetValue;
  final IconData? icon;
  final bool digitsOnly;

  Future<T?> show(BuildContext context) async {
    return showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final localizations = MaterialLocalizations.of(context);

    final textController = useTextEditingController(
      text: initialValue?.toString(),
    );

    return AlertDialog(
      title: Text(title),
      icon: icon != null ? Icon(icon) : null,
      content: TextFormField(
        controller: textController,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
          if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        ],
        autovalidateMode: AutovalidateMode.always,
      ),
      actions: [
        if (resetValue != null)
          TextButton(
            onPressed: () async {
              await Navigator.of(context).maybePop(resetValue);
            },
            child: Text(t.general.reset.toUpperCase()),
          ),
        TextButton(
          onPressed: () async {
            await Navigator.of(context).maybePop();
          },
          child: Text(localizations.cancelButtonLabel.toUpperCase()),
        ),
        TextButton(
          onPressed: () async {
            if (mapTo != null) {
              await Navigator.of(context)
                  .maybePop(mapTo!.call(textController.value.text));
            } else {
              await Navigator.of(context)
                  .maybePop(T == String ? textController.value.text : null);
            }
          },
          child: Text(localizations.okButtonLabel.toUpperCase()),
        ),
      ],
    );
  }
}
