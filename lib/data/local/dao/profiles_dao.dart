import 'package:drift/drift.dart';
import 'package:hiddify/data/local/data_mappers.dart';
import 'package:hiddify/data/local/database.dart';
import 'package:hiddify/data/local/tables.dart';
import 'package:hiddify/domain/enums.dart';
import 'package:hiddify/domain/profiles/profiles.dart';
import 'package:hiddify/utils/utils.dart';

part 'profiles_dao.g.dart';

Map<SortMode, OrderingMode> orderMap = {
  SortMode.ascending: OrderingMode.asc,
  SortMode.descending: OrderingMode.desc
};

@DriftAccessor(tables: [ProfileEntries])
class ProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$ProfilesDaoMixin, InfraLogger {
  ProfilesDao(super.db);

  Future<Profile?> getById(String id) async {
    return (profileEntries.select()..where((tbl) => tbl.id.equals(id)))
        .map(ProfileMapper.fromEntry)
        .getSingleOrNull();
  }

  Stream<Profile?> watchActiveProfile() {
    return (profileEntries.select()..where((tbl) => tbl.active.equals(true)))
        .map(ProfileMapper.fromEntry)
        .watchSingleOrNull();
  }

  Stream<int> watchProfileCount() {
    final count = profileEntries.id.count();
    return (profileEntries.selectOnly()..addColumns([count]))
        .map((exp) => exp.read(count)!)
        .watchSingle();
  }

  Stream<List<Profile>> watchAll({
    ProfilesSort sort = ProfilesSort.lastUpdate,
    SortMode mode = SortMode.ascending,
  }) {
    return (profileEntries.select()
          ..orderBy(
            [
              switch (sort) {
                ProfilesSort.name => (tbl) => OrderingTerm(
                      expression: tbl.name,
                      mode: orderMap[mode]!,
                    ),
                _ => (tbl) => OrderingTerm(
                      expression: tbl.lastUpdate,
                      mode: orderMap[mode]!,
                    ),
              }
            ],
          ))
        .map(ProfileMapper.fromEntry)
        .watch();
  }

  Future<void> create(Profile profile) async {
    await transaction(
      () async {
        if (profile.active) {
          await (update(profileEntries)
                ..where((tbl) => tbl.id.isNotValue(profile.id)))
              .write(const ProfileEntriesCompanion(active: Value(false)));
        }
        await into(profileEntries).insert(profile.toCompanion());
      },
    );
  }

  Future<void> edit(Profile patch) async {
    await transaction(
      () async {
        await (update(profileEntries)..where((tbl) => tbl.id.equals(patch.id)))
            .write(patch.toCompanion());
      },
    );
  }

  Future<void> setAsActive(String id) async {
    await transaction(
      () async {
        await (update(profileEntries)..where((tbl) => tbl.id.isNotValue(id)))
            .write(const ProfileEntriesCompanion(active: Value(false)));
        await (update(profileEntries)..where((tbl) => tbl.id.equals(id)))
            .write(const ProfileEntriesCompanion(active: Value(true)));
      },
    );
  }

  Future<void> removeById(String id) async {
    await transaction(
      () async {
        await (delete(profileEntries)..where((tbl) => tbl.id.equals(id))).go();
      },
    );
  }
}
