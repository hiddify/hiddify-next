import 'package:duration/duration.dart';

// TODO: use a better solution
String formatExpireDuration(Duration dur) {
  return prettyDuration(
    dur,
    upperTersity: DurationTersity.day,
    tersity: DurationTersity.day,
  );
}
