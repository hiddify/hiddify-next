import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cronKeyPrefix = "cron_";

typedef Job<T> = (
  String key,
  Duration duration,
  FutureOr<T?> Function() callback,
);

class CronService with InfraLogger {
  CronService(this.prefs);

  final SharedPreferences prefs;

  NeatPeriodicTaskScheduler? _scheduler;
  Map<String, Job> jobs = {};

  void schedule<T>({
    required String key,
    required Duration duration,
    required FutureOr<T?> Function() callback,
  }) {
    loggy.debug("scheduling [$key]");
    jobs[key] = (key, duration, callback);
  }

  Future<void> run(Job job) async {
    final key = job.$1;
    final prefKey = "$_cronKeyPrefix$key";
    final previousRunTime = DateTime.tryParse(prefs.getString(prefKey) ?? "");
    loggy.debug(
      "[$key] > ${previousRunTime == null ? "first run" : "previous run on [$previousRunTime]"}",
    );

    if (previousRunTime != null &&
        previousRunTime.add(job.$2) > DateTime.now()) {
      loggy.debug("[$key] > didn't meet criteria");
      return;
    }

    final result = await job.$3();
    await prefs.setString(prefKey, DateTime.now().toIso8601String());
    return result;
  }

  Future<void> startScheduler() async {
    loggy.debug("starting job scheduler");
    await _scheduler?.stop();
    int runCount = 0;
    _scheduler = NeatPeriodicTaskScheduler(
      name: "cron job scheduler",
      interval: const Duration(minutes: 10),
      timeout: const Duration(minutes: 5),
      minCycle: const Duration(minutes: 2),
      task: () {
        loggy.debug("in run ${runCount++}");
        return Future.wait(jobs.values.map(run));
      },
    );
    _scheduler!.start();
  }

  Future<void> stopScheduler() async {
    loggy.debug("stopping job scheduler");
    return _scheduler?.stop();
  }
}
