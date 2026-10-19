import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class TripsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get treasurerId => text()();
  TextColumn get activeScenarioId => text()();
  BoolColumn get isLedgerInitialized => boolean().withDefault(const Constant(false))();
  TextColumn get ledgerScenarioId => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class MembersTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get name => text()();
  BoolColumn get isTreasurer => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class StagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get name => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpensesTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get stageId => text()();
  TextColumn get stageIdsJson => text().withDefault(const Constant('[]'))();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get calcMode => text()();
  IntColumn get estimatedTotal => integer().withDefault(const Constant(0))();
  IntColumn get unitPrice => integer().withDefault(const Constant(0))();
  TextColumn get lineItemsJson => text().withDefault(const Constant('[]'))();
  IntColumn get shippingFee => integer().withDefault(const Constant(0))();
  IntColumn get discountFee => integer().withDefault(const Constant(0))();
  TextColumn get shippingRule => text().withDefault(const Constant('equalSplit'))();
  TextColumn get discountRule => text().withDefault(const Constant('proportionalToSubtotal'))();
  BoolColumn get isCommitted => boolean().withDefault(const Constant(false))();
  TextColumn get costBearersJson => text().withDefault(const Constant('{}'))();
  IntColumn get actualPrice => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ScenariosTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isBaseline => boolean().withDefault(const Constant(false))();
  TextColumn get stageAttendancesJson => text().withDefault(const Constant('{}'))();
  TextColumn get costBearerOverridesJson => text().withDefault(const Constant('{}'))();
  TextColumn get expenseAmountOverridesJson => text().withDefault(const Constant('{}'))();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

class CashTransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get expenseId => text().nullable()();
  TextColumn get type => text()();
  TextColumn get payerMemberId => text()();
  TextColumn get recipient => text()();
  IntColumn get amount => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get businessKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ActualBooksTable extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get sourceScenarioId => text()();
  TextColumn get snapshotJson => text()();
  BoolColumn get isSettled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  TripsTable,
  MembersTable,
  StagesTable,
  ExpensesTable,
  ScenariosTable,
  CashTransactionsTable,
  ActualBooksTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'group_travel_db');
  }
}
