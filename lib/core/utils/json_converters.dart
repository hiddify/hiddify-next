import 'package:dart_mappable/dart_mappable.dart';

class IntervalInSecondsMapper extends SimpleMapper<Duration> {
  const IntervalInSecondsMapper();

  @override
  Duration decode(dynamic value) => Duration(seconds: value as int);

  @override
  dynamic encode(Duration self) => self.inSeconds;
}
