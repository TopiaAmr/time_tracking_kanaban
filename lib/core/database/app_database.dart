import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Tasks table for caching tasks from the API
class TasksTable extends Table {
  TextColumn get userId => text()();
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get sectionId => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get addedByUid => text()();
  TextColumn get assignedByUid => text().nullable()();
  TextColumn get responsibleUid => text().nullable()();
  TextColumn get labels => text().map(const ListConverter())();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get duration => integer().nullable()();
  BoolColumn get checked => boolean()();
  BoolColumn get isDeleted => boolean()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get completedByUid => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get due => dateTime().nullable()();
  IntColumn get priority => integer()();
  IntColumn get childOrder => integer()();
  TextColumn get content => text()();
  TextColumn get description => text()();
  IntColumn get noteCount => integer()();
  IntColumn get dayOrder => integer()();
  BoolColumn get isCollapsed => boolean()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Projects table for caching projects from the API
class ProjectsTable extends Table {
  TextColumn get id => text()();
  BoolColumn get canAssignTasks => boolean()();
  IntColumn get childOrder => integer()();
  TextColumn get color => text()();
  TextColumn get creatorUid => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isArchived => boolean()();
  BoolColumn get isDeleted => boolean()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isFrozen => boolean()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get viewStyle => text()();
  IntColumn get defaultOrder => integer()();
  TextColumn get description => text()();
  BoolColumn get publicAccess => boolean()();
  TextColumn get publicKey => text()();
  TextColumn get accessVisibility => text()();
  TextColumn get accessConfiguration => text().map(const MapConverter())();
  TextColumn get role => text()();
  TextColumn get parentId => text().nullable()();
  BoolColumn get inboxProject => boolean()();
  BoolColumn get isCollapsed => boolean()();
  BoolColumn get isShared => boolean()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sections table for caching sections from the API
class SectionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get projectId => text()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  TextColumn get name => text()();
  IntColumn get sectionOrder => integer()();
  BoolColumn get isArchived => boolean()();
  BoolColumn get isDeleted => boolean()();
  BoolColumn get isCollapsed => boolean()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Comments table for storing comments locally
class CommentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get authorId => text()();
  TextColumn get authorName => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Time logs table for storing timer records
class TimeLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    TasksTable,
    ProjectsTable,
    SectionsTable,
    CommentsTable,
    TimeLogsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([LazyDatabase? database]) : super(database ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here when schema version changes
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}

/// Converter for storing `List<String>` as text in database
class ListConverter extends TypeConverter<List<String>, String> {
  const ListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}

/// Converter for storing `Map<String, dynamic>` as text in database
class MapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const MapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    try {
      return jsonDecode(fromDb) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return jsonEncode(value);
  }
}
