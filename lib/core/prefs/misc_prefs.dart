import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/utils/pref_notifier.dart';

final connectionTestUrlProvider =
    PrefNotifier.provider("connection_test_url", Defaults.connectionTestUrl);

final concurrentTestCountProvider = PrefNotifier.provider(
  "concurrent_test_count",
  Defaults.concurrentTestCount,
);
