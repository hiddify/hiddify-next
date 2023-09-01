import 'package:hiddify/utils/pref_notifier.dart';

final silentStartProvider = PrefNotifier.provider("silent_start", false);

final debugModeProvider = PrefNotifier.provider("debug_mode", false);
