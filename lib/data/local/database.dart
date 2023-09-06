import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// import 'package:hiddify/data/local/dao/dao.dart';
import 'package:hiddify/data/local/dao/profiles_dao.dart'; // TODO https://github.com/simolus3/drift/issues/2589
import 'package:hiddify/data/local/tables.dart';
import 'package:hiddify/data/local/type_converters.dart';
import 'package:hiddify/services/files_editor_service.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [ProfileEntries], daos: [ProfilesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({required QueryExecutor connection}) : super(connection);

  AppDatabase.connect() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await FilesEditorService.getDatabaseDirectory();
    final file = File(p.join(dbDir.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
