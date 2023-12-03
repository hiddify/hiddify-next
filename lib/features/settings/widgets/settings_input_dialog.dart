import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsInputDialog<T> extends HookConsumerWidget with PresLogger {
  const SettingsInputDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.mapTo,
    this.validator,
    this.resetValue,
    this.optionalAction,
    this.icon,
    this.digitsOnly = false,
  });

  final String title;
  final T initialValue;
  final T? Function(String value)? mapTo;
  final bool Function(String value)? validator;
  final T? resetValue;
  final (String text, VoidCallback)? optionalAction;
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
        if (optionalAction != null)
          TextButton(
            onPressed: () async {
              optionalAction!.$2();
              await Navigator.of(context)
                  .maybePop(T == String ? textController.value.text : null);
            },
            child: Text(optionalAction!.$1.toUpperCase()),
          ),
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
            if (validator?.call(textController.value.text) == false) {
              await Navigator.of(context).maybePop(null);
            } else if (mapTo != null) {
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

class SettingsPickerDialog<T> extends HookConsumerWidget with PresLogger {
  const SettingsPickerDialog({
    super.key,
    required this.title,
    required this.selected,
    required this.options,
    required this.getTitle,
    this.resetValue,
  });

  final String title;
  final T selected;
  final List<T> options;
  final String Function(T e) getTitle;
  final T? resetValue;

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

    return AlertDialog(
      title: Text(title),
      content: Column(
        children: options
            .map(
              (e) => RadioListTile(
                title: Text(getTitle(e)),
                value: e,
                groupValue: selected,
                onChanged: (value) => context.pop(e),
              ),
            )
            .toList(),
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
      ],
      scrollable: true,
    );
  }
}

class SettingsSliderDialog extends HookConsumerWidget with PresLogger {
  const SettingsSliderDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.resetValue,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.labelGen,
  });

  final String title;
  final double initialValue;
  final double? resetValue;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double value)? labelGen;

  Future<double?> show(BuildContext context) async {
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

    final sliderValue = useState(initialValue);

    return AlertDialog(
      title: Text(title),
      content: IntrinsicHeight(
        child: Slider(
          value: sliderValue.value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (value) => sliderValue.value = value,
          label: labelGen?.call(sliderValue.value),
        ),
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
            await Navigator.of(context).maybePop(sliderValue.value);
          },
          child: Text(localizations.okButtonLabel.toUpperCase()),
        ),
      ],
    );
  }
}
