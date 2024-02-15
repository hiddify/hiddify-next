import 'package:dart_mappable/dart_mappable.dart';
import 'package:dartx/dartx.dart';
import 'package:hiddify/core/localization/translations.dart';

part 'optional_range.mapper.dart';

@MappableClass()
class OptionalRange with OptionalRangeMappable {
  const OptionalRange({this.min, this.max});

  final int? min;
  final int? max;

  String format() => [min, max].whereNotNull().join("-");
  String present(TranslationsEn t) =>
      format().isEmpty ? t.general.notSet : format();

  factory OptionalRange._fromString(
    String input, {
    bool allowEmpty = true,
  }) =>
      switch (input.split("-")) {
        [final String val] when val.isEmpty && allowEmpty =>
          const OptionalRange(),
        [final String min] => OptionalRange(min: int.parse(min)),
        [final String min, final String max] => OptionalRange(
            min: int.parse(min),
            max: int.parse(max),
          ),
        _ => throw Exception("Invalid range: $input"),
      };

  static OptionalRange? tryParse(
    String input, {
    bool allowEmpty = false,
  }) {
    try {
      return OptionalRange._fromString(input);
    } catch (_) {
      return null;
    }
  }
}

class OptionalRangeJsonMapper extends SimpleMapper<OptionalRange> {
  const OptionalRangeJsonMapper();

  @override
  OptionalRange decode(dynamic value) =>
      OptionalRange._fromString(value as String);

  @override
  dynamic encode(OptionalRange self) => self.format();
}
