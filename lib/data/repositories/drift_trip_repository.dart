import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/member.dart';
import '../../domain/models/stage.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/services/trip_repository.dart';
import '../database/app_database.dart';
import '../fixtures/golden_fixture.dart';

class DriftTripRepository implements TripRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  DriftTripRepository({AppDatabase? database}) : db = database ?? AppDatabase();

  Future<void> ensureSampleDataSeeded() async {
    final count = await db.select(db.tripsTable).get();
    if (count.isEmpty) {
      final goldenTrip = GoldenFixture.createGoldenTrip();
      await saveTrip(goldenTrip);
    }
  }

  @override
  Future<List<Trip>> getTrips() async {
    await ensureSampleDataSeeded();
    final tripRows = await (db.select(db.tripsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();

    final List<Trip> trips = [];
    for (final row in tripRows) {
      final trip = await _buildTripFromRow(row);
      trips.add(trip);
    }
    return trips;
  }

  @override
  Future<Trip?> getTripById(String id) async {
    await ensureSampleDataSeeded();
    final row = await (db.select(db.tripsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return _buildTripFromRow(row);
  }

  Future<Trip> _buildTripFromRow(TripsTableData row) async {
    final tripId = row.id;

    // Load members
    final memberRows = await (db.select(db.membersTable)
          ..where((m) => m.tripId.equals(tripId))
          ..orderBy([(m) => OrderingTerm.asc(m.orderIndex)]))
        .get();
    final members = memberRows
        .map((m) => Member(
              id: m.id,
              name: m.name,
              isTreasurer: m.isTreasurer,
              isActive: m.isActive,
            ))
        .toList();

    // Load stages
    final stageRows = await (db.select(db.stagesTable)
          ..where((s) => s.tripId.equals(tripId))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();
    final stages = stageRows
        .map((s) => Stage(
              id: s.id,
              name: s.name,
              order: s.orderIndex,
              description: s.description,
            ))
        .toList();

    // Load expenses
    final expenseRows = await (db.select(db.expensesTable)
          ..where((e) => e.tripId.equals(tripId)))
        .get();
    final expenses = expenseRows.map((e) {
      final stageIds = (jsonDecode(e.stageIdsJson) as List<dynamic>?)
              ?.map((x) => x as String)
              .toList() ??
          <String>[];
      final lineItems = (jsonDecode(e.lineItemsJson) as List<dynamic>?)
              ?.map((x) => LineItem.fromJson(x as Map<String, dynamic>))
              .toList() ??
          <LineItem>[];
      final costBearers = (jsonDecode(e.costBearersJson) as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(
                  k,
                  CostBearerStatus.values.firstWhere(
                    (s) => s.name == v,
                    orElse: () => CostBearerStatus.inherited,
                  ))) ??
          <String, CostBearerStatus>{};

      return Expense(
        id: e.id,
        stageId: e.stageId,
        stageIds: stageIds,
        title: e.title,
        description: e.description,
        calcMode: ExpenseCalcMode.values.firstWhere(
          (m) => m.name == e.calcMode,
          orElse: () => ExpenseCalcMode.fixedEqual,
        ),
        estimatedTotal: e.estimatedTotal,
        unitPrice: e.unitPrice,
        lineItems: lineItems,
        shippingFee: e.shippingFee,
        discountFee: e.discountFee,
        shippingRule: ModifierAllocationRule.values.firstWhere(
          (r) => r.name == e.shippingRule,
          orElse: () => ModifierAllocationRule.equalSplit,
        ),
        discountRule: ModifierAllocationRule.values.firstWhere(
          (r) => r.name == e.discountRule,
          orElse: () => ModifierAllocationRule.proportionalToSubtotal,
        ),
        isCommitted: e.isCommitted,
        costBearers: costBearers,
        actualPrice: e.actualPrice,
      );
    }).toList();

    // Load scenarios
    final scenarioRows = await (db.select(db.scenariosTable)
          ..where((sc) => sc.tripId.equals(tripId)))
        .get();
    final scenarios = scenarioRows.map((sc) {
      final attendancesRaw =
          jsonDecode(sc.stageAttendancesJson) as Map<String, dynamic>? ?? {};
      final stageAttendances = attendancesRaw.map(
        (k, v) => MapEntry(
            k, (v as List<dynamic>).map((mId) => mId as String).toSet()),
      );

      final overridesRaw =
          jsonDecode(sc.costBearerOverridesJson) as Map<String, dynamic>? ?? {};
      final costBearerOverrides = overridesRaw.map(
        (expId, map) => MapEntry(
          expId,
          (map as Map<String, dynamic>).map(
            (mId, sName) => MapEntry(
              mId,
              CostBearerStatus.values.firstWhere(
                (status) => status.name == sName,
                orElse: () => CostBearerStatus.inherited,
              ),
            ),
          ),
        ),
      );

      final amountOverridesRaw =
          jsonDecode(sc.expenseAmountOverridesJson) as Map<String, dynamic>? ?? {};
      final expenseAmountOverrides = amountOverridesRaw.map(
        (k, v) => MapEntry(k, v as int),
      );

      return Scenario(
        id: sc.id,
        name: sc.name,
        description: sc.description,
        isBaseline: sc.isBaseline,
        stageAttendances: stageAttendances,
        costBearerOverrides: costBearerOverrides,
        expenseAmountOverrides: expenseAmountOverrides,
        isStale: sc.isStale,
      );
    }).toList();

    // Load cash transactions
    final txRows = await (db.select(db.cashTransactionsTable)
          ..where((tx) => tx.tripId.equals(tripId))
          ..orderBy([(tx) => OrderingTerm.asc(tx.timestamp)]))
        .get();
    final cashTransactions = txRows.map((tx) {
      return CashTransaction(
        id: tx.id,
        tripId: tx.tripId,
        expenseId: tx.expenseId,
        type: CashTransactionType.values.firstWhere(
          (t) => t.name == tx.type,
          orElse: () => CashTransactionType.fundContribution,
        ),
        payerMemberId: tx.payerMemberId,
        recipient: tx.recipient,
        amount: tx.amount,
        note: tx.note,
        timestamp: tx.timestamp,
        businessKey: tx.businessKey,
      );
    }).toList();

    Map<String, dynamic> metadata = {};
    try {
      metadata = jsonDecode(row.metadataJson) as Map<String, dynamic>;
    } catch (_) {}
    metadata['revision'] = row.revision;

    return Trip(
      id: row.id,
      name: row.name,
      description: row.description,
      treasurerId: row.treasurerId,
      activeScenarioId: row.activeScenarioId,
      isLedgerInitialized: row.isLedgerInitialized,
      ledgerScenarioId: row.ledgerScenarioId,
      members: members,
      stages: stages,
      expenses: expenses,
      scenarios: scenarios,
      cashTransactions: cashTransactions,
      metadata: metadata,
    );
  }

  @override
  Future<Trip> saveTrip(Trip trip, {int? expectedRevision}) async {
    return db.transaction(() async {
      // Concurrency check
      final existingRow = await (db.select(db.tripsTable)
            ..where((t) => t.id.equals(trip.id)))
          .getSingleOrNull();

      int newRevision = 1;
      if (existingRow != null) {
        if (expectedRevision != null && existingRow.revision != expectedRevision) {
          throw StateError(
              'Xung đột dữ liệu: Chuyến đi đã được cập nhật bởi một phiên làm việc khác (phiên bản hiện tại: ${existingRow.revision}, phiên bản mong đợi: $expectedRevision). Vui lòng tải lại trước khi lưu.');
        }
        newRevision = existingRow.revision + 1;
      }

      final metadataMap = Map<String, dynamic>.from(trip.metadata);
      metadataMap['revision'] = newRevision;
      final metadataJson = jsonEncode(metadataMap);

      // Upsert trip
      await db.into(db.tripsTable).insertOnConflictUpdate(
            TripsTableCompanion(
              id: Value(trip.id),
              name: Value(trip.name),
              description: Value(trip.description),
              treasurerId: Value(trip.treasurerId),
              activeScenarioId: Value(trip.activeScenarioId),
              isLedgerInitialized: Value(trip.isLedgerInitialized),
              ledgerScenarioId: Value(trip.ledgerScenarioId),
              revision: Value(newRevision),
              metadataJson: Value(metadataJson),
              updatedAt: Value(DateTime.now()),
            ),
          );

      // Sync members
      await (db.delete(db.membersTable)..where((m) => m.tripId.equals(trip.id)))
          .go();
      for (int i = 0; i < trip.members.length; i++) {
        final m = trip.members[i];
        await db.into(db.membersTable).insert(
              MembersTableCompanion(
                id: Value(m.id),
                tripId: Value(trip.id),
                name: Value(m.name),
                isTreasurer: Value(m.isTreasurer),
                isActive: Value(m.isActive),
                orderIndex: Value(i),
              ),
            );
      }

      // Sync stages
      await (db.delete(db.stagesTable)..where((s) => s.tripId.equals(trip.id)))
          .go();
      for (final s in trip.stages) {
        await db.into(db.stagesTable).insert(
              StagesTableCompanion(
                id: Value(s.id),
                tripId: Value(trip.id),
                name: Value(s.name),
                orderIndex: Value(s.order),
                description: Value(s.description),
              ),
            );
      }

      // Sync expenses
      await (db.delete(db.expensesTable)..where((e) => e.tripId.equals(trip.id)))
          .go();
      for (final e in trip.expenses) {
        await db.into(db.expensesTable).insert(
              ExpensesTableCompanion(
                id: Value(e.id),
                tripId: Value(trip.id),
                stageId: Value(e.stageId),
                stageIdsJson: Value(jsonEncode(e.stageIds)),
                title: Value(e.title),
                description: Value(e.description),
                calcMode: Value(e.calcMode.name),
                estimatedTotal: Value(e.estimatedTotal),
                unitPrice: Value(e.unitPrice),
                lineItemsJson: Value(
                    jsonEncode(e.lineItems.map((li) => li.toJson()).toList())),
                shippingFee: Value(e.shippingFee),
                discountFee: Value(e.discountFee),
                shippingRule: Value(e.shippingRule.name),
                discountRule: Value(e.discountRule.name),
                isCommitted: Value(e.isCommitted),
                costBearersJson: Value(jsonEncode(e.costBearers
                    .map((k, v) => MapEntry(k, v.name)))),
                actualPrice: Value(e.actualPrice),
              ),
            );
      }

      // Sync scenarios
      await (db.delete(db.scenariosTable)
            ..where((sc) => sc.tripId.equals(trip.id)))
          .go();
      for (final sc in trip.scenarios) {
        await db.into(db.scenariosTable).insert(
              ScenariosTableCompanion(
                id: Value(sc.id),
                tripId: Value(trip.id),
                name: Value(sc.name),
                description: Value(sc.description),
                isBaseline: Value(sc.isBaseline),
                stageAttendancesJson: Value(jsonEncode(sc.stageAttendances
                    .map((k, v) => MapEntry(k, v.toList())))),
                costBearerOverridesJson: Value(jsonEncode(sc
                    .costBearerOverrides
                    .map((expId, map) => MapEntry(expId,
                        map.map((mId, status) => MapEntry(mId, status.name)))))),
                expenseAmountOverridesJson:
                    Value(jsonEncode(sc.expenseAmountOverrides)),
                isStale: Value(sc.isStale),
                revision: Value(newRevision),
              ),
            );
      }

      // Sync cash transactions
      await (db.delete(db.cashTransactionsTable)
            ..where((tx) => tx.tripId.equals(trip.id)))
          .go();
      for (final tx in trip.cashTransactions) {
        await db.into(db.cashTransactionsTable).insert(
              CashTransactionsTableCompanion(
                id: Value(tx.id),
                tripId: Value(trip.id),
                expenseId: Value(tx.expenseId),
                type: Value(tx.type.name),
                payerMemberId: Value(tx.payerMemberId),
                recipient: Value(tx.recipient),
                amount: Value(tx.amount),
                note: Value(tx.note),
                timestamp: Value(tx.timestamp),
                businessKey: Value(tx.businessKey),
              ),
            );
      }

      return trip.copyWith(metadata: metadataMap);
    });
  }

  @override
  Future<void> deleteTrip(String id) async {
    await db.transaction(() async {
      await (db.delete(db.cashTransactionsTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.scenariosTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.expensesTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.stagesTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.membersTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.actualBooksTable)..where((t) => t.tripId.equals(id))).go();
      await (db.delete(db.tripsTable)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<Trip> duplicateTrip(String id, {String? newName}) async {
    final existing = await getTripById(id);
    if (existing == null) {
      throw ArgumentError('Không tìm thấy chuyến đi có ID: $id để nhân bản');
    }

    final newTripId = 'trip_${_uuid.v4()}';
    final name = newName ?? '${existing.name} (Bản sao)';

    // Remap member IDs
    final memberIdMap = <String, String>{};
    final newMembers = existing.members.map((m) {
      final newMemberId = 'm_${_uuid.v4()}';
      memberIdMap[m.id] = newMemberId;
      return m.copyWith(id: newMemberId);
    }).toList();

    // Remap stage IDs
    final stageIdMap = <String, String>{};
    final newStages = existing.stages.map((s) {
      final newStageId = 'stage_${_uuid.v4()}';
      stageIdMap[s.id] = newStageId;
      return s.copyWith(id: newStageId);
    }).toList();

    // Remap expense IDs & bearers
    final expenseIdMap = <String, String>{};
    final newExpenses = existing.expenses.map((e) {
      final newExpenseId = 'exp_${_uuid.v4()}';
      expenseIdMap[e.id] = newExpenseId;

      final newStageId = stageIdMap[e.stageId] ?? e.stageId;
      final newStageIds =
          e.stageIds.map((sId) => stageIdMap[sId] ?? sId).toList();

      final newCostBearers = e.costBearers.map((mId, status) {
        return MapEntry(memberIdMap[mId] ?? mId, status);
      });

      final newLineItems = e.lineItems.map((li) {
        return li.copyWith(
          id: 'item_${_uuid.v4()}',
          bearerMemberId: memberIdMap[li.bearerMemberId] ?? li.bearerMemberId,
        );
      }).toList();

      return e.copyWith(
        id: newExpenseId,
        stageId: newStageId,
        stageIds: newStageIds,
        costBearers: newCostBearers,
        lineItems: newLineItems,
      );
    }).toList();

    // Remap scenarios
    final scenarioIdMap = <String, String>{};
    final newScenarios = existing.scenarios.map((sc) {
      final newScenarioId = 'scenario_${_uuid.v4()}';
      scenarioIdMap[sc.id] = newScenarioId;

      final newStageAttendances = sc.stageAttendances.map((sId, membersSet) {
        final mappedStageId = stageIdMap[sId] ?? sId;
        final mappedMembers =
            membersSet.map((mId) => memberIdMap[mId] ?? mId).toSet();
        return MapEntry(mappedStageId, mappedMembers);
      });

      final newCostBearerOverrides = sc.costBearerOverrides.map((eId, map) {
        final mappedExpId = expenseIdMap[eId] ?? eId;
        final mappedMap = map.map(
          (mId, status) => MapEntry(memberIdMap[mId] ?? mId, status),
        );
        return MapEntry(mappedExpId, mappedMap);
      });

      final newAmountOverrides = sc.expenseAmountOverrides.map((eId, amount) {
        return MapEntry(expenseIdMap[eId] ?? eId, amount);
      });

      return sc.copyWith(
        id: newScenarioId,
        stageAttendances: newStageAttendances,
        costBearerOverrides: newCostBearerOverrides,
        expenseAmountOverrides: newAmountOverrides,
      );
    }).toList();

    // Remap transactions
    final newTransactions = existing.cashTransactions.map((tx) {
      final mappedPayer = memberIdMap[tx.payerMemberId] ?? tx.payerMemberId;
      final mappedRecipient = memberIdMap[tx.recipient] ?? tx.recipient;
      final mappedExpId = tx.expenseId != null ? expenseIdMap[tx.expenseId] : null;

      return tx.copyWith(
        id: 'tx_${_uuid.v4()}',
        tripId: newTripId,
        expenseId: mappedExpId,
        payerMemberId: mappedPayer,
        recipient: mappedRecipient,
      );
    }).toList();

    final duplicated = Trip(
      id: newTripId,
      name: name,
      description: existing.description,
      treasurerId: memberIdMap[existing.treasurerId] ?? existing.treasurerId,
      members: newMembers,
      stages: newStages,
      expenses: newExpenses,
      scenarios: newScenarios,
      activeScenarioId: scenarioIdMap[existing.activeScenarioId] ??
          (newScenarios.isNotEmpty ? newScenarios.first.id : ''),
      isLedgerInitialized: existing.isLedgerInitialized,
      ledgerScenarioId: existing.ledgerScenarioId != null
          ? scenarioIdMap[existing.ledgerScenarioId]
          : null,
      cashTransactions: newTransactions,
      metadata: {
        ...existing.metadata,
        'duplicatedFrom': id,
        'createdAt': DateTime.now().toIso8601String(),
        'isSampleData': false,
      },
    );

    return saveTrip(duplicated);
  }
}
