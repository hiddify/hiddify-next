import 'package:drift/drift.dart';
import 'package:hiddify/data/local/type_converters.dart';

@DataClassName('ProfileEntry')
class ProfileEntries extends Table {
  TextColumn get id => text()();
  BoolColumn get active => boolean()();
  TextColumn get name => text().withLength(min: 1)();
  TextColumn get url => text()();
  DateTimeColumn get lastUpdate => dateTime()();
  IntColumn get updateInterval =>
      integer().nullable().map(DurationTypeConverter())();
  IntColumn get upload => integer().nullable()();
  IntColumn get download => integer().nullable()();
  IntColumn get total => integer().nullable()();
  DateTimeColumn get expire => dateTime().nullable()();
  TextColumn get webPageUrl => text().nullable()();
  TextColumn get supportUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
