import 'package:freezed_annotation/freezed_annotation.dart';

part 'range.freezed.dart';

@freezed
class RangeWithOptionalCeil with _$RangeWithOptionalCeil {
  const RangeWithOptionalCeil._();

  const factory RangeWithOptionalCeil({
    required int min,
    int? max,
  }) = _RangeWithOptionalCeil;

  String format() => "$min${max != null ? "-$max" : ""}";

  factory RangeWithOptionalCeil.fromString(String input) =>
      switch (input.split("-")) {
        [final String min] => RangeWithOptionalCeil(min: int.parse(min)),
        [final String min, final String max] => RangeWithOptionalCeil(
            min: int.parse(min),
            max: int.parse(max),
          ),
        _ => throw Exception("Invalid range: $input"),
      };

  static RangeWithOptionalCeil? tryParse(String input) {
    try {
      return RangeWithOptionalCeil.fromString(input);
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
      RangeWithOptionalCeil.fromString(json);

  @override
  String toJson(RangeWithOptionalCeil object) => object.format();
}
