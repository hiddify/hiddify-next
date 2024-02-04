import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/localization/translations.dart';

part 'range.freezed.dart';

@freezed
class RangeWithOptionalCeil with _$RangeWithOptionalCeil {
  const RangeWithOptionalCeil._();

  const factory RangeWithOptionalCeil({
    int? min,
    int? max,
  }) = _RangeWithOptionalCeil;

  String format() => [min, max].whereNotNull().join("-");
  String present(TranslationsEn t) =>
      format().isEmpty ? t.general.notSet : format();

  factory RangeWithOptionalCeil._fromString(
    String input, {
    bool allowEmpty = true,
  }) =>
      switch (input.split("-")) {
        [final String val] when val.isEmpty && allowEmpty =>
          const RangeWithOptionalCeil(),
        [final String min] => RangeWithOptionalCeil(min: int.parse(min)),
        [final String min, final String max] => RangeWithOptionalCeil(
            min: int.parse(min),
            max: int.parse(max),
          ),
        _ => throw Exception("Invalid range: $input"),
      };

  static RangeWithOptionalCeil? tryParse(
    String input, {
    bool allowEmpty = false,
  }) {
    try {
      return RangeWithOptionalCeil._fromString(input);
    } catch (_) {
      return null;
    }
  }
}

class RangeWithOptionalCeilJsonConverter
    implements JsonConverter<RangeWithOptionalCeil, String> {
  const RangeWithOptionalCeilJsonConverter();

  @override
  RangeWithOptionalCeil fromJson(String json) =>
      RangeWithOptionalCeil._fromString(json);

  @override
  String toJson(RangeWithOptionalCeil object) => object.format();
}
