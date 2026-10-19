import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../domain/models/trip.dart';
import '../../domain/services/backup_import_service.dart';
import '../../domain/services/trip_repository.dart';

class RealBackupImportService implements BackupImportService {
  final Uuid _uuid = const Uuid();

  @override
  Future<String> exportBackupJson({
    required Trip trip,
    bool allTrips = false,
    List<Trip>? trips,
  }) async {
    final Map<String, dynamic> exportData;

    if (allTrips && trips != null) {
      exportData = {
        'exportType': 'all_trips',
        'exportedAt': DateTime.now().toIso8601String(),
        'fileFormat': '.grouptrip.json',
        'schemaVersion': '2.0.0',
        'algorithmVersion': 'v2-exact-largest-remainder',
        'trips': trips.map((t) => t.toJson()).toList(),
      };
    } else {
      exportData = {
        'exportType': 'single_trip',
        'exportedAt': DateTime.now().toIso8601String(),
        'fileFormat': '.grouptrip.json',
        'schemaVersion': '2.0.0',
        'algorithmVersion': 'v2-exact-largest-remainder',
        'trip': trip.toJson(),
      };
    }

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(exportData);
  }

  Future<List<Trip>> previewAllTrips(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Định dạng file không hợp lệ (không phải đối tượng JSON)');
      }

      final schemaVersion = decoded['schemaVersion'] as String?;
      if (schemaVersion == null) {
        throw const FormatException('Thiếu metadata phiên bản cấu trúc (schemaVersion)');
      }

      // Validate supported schema versions
      if (!schemaVersion.startsWith('1.') && !schemaVersion.startsWith('2.')) {
        throw FormatException('Phiên bản schema không được hỗ trợ: $schemaVersion');
      }

      final List<Trip> trips = [];

      if (decoded.containsKey('trips')) {
        final list = decoded['trips'] as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            trips.add(Trip.fromJson(item));
          }
        }
      } else if (decoded.containsKey('trip')) {
        trips.add(Trip.fromJson(decoded['trip'] as Map<String, dynamic>));
      } else if (decoded.containsKey('id') && decoded.containsKey('name')) {
        trips.add(Trip.fromJson(decoded));
      }

      if (trips.isEmpty) {
        throw const FormatException('Không tìm thấy dữ liệu chuyến đi nào trong file');
      }

      return trips;
    } catch (e) {
      throw FormatException('Không thể đọc file sao lưu: ${e.toString()}');
    }
  }

  @override
  Future<Trip> previewImportJson(String jsonString) async {
    final all = await previewAllTrips(jsonString);
    return all.first;
  }

  Future<List<Trip>> commitImportAll({
    required String jsonString,
    required TripRepository repository,
    List<String>? selectedTripIds,
  }) async {
    final allTrips = await previewAllTrips(jsonString);
    final targetTrips = selectedTripIds != null
        ? allTrips.where((t) => selectedTripIds.contains(t.id)).toList()
        : allTrips;

    final importedTrips = <Trip>[];

    for (final parsedTrip in targetTrips) {
      final newTripId = 'trip_imported_${_uuid.v4()}';

      // Remap member IDs
      final memberIdMap = <String, String>{};
      final newMembers = parsedTrip.members.map((m) {
        final newMemberId = 'm_${_uuid.v4()}';
        memberIdMap[m.id] = newMemberId;
        return m.copyWith(id: newMemberId);
      }).toList();

      // Remap stage IDs
      final stageIdMap = <String, String>{};
      final newStages = parsedTrip.stages.map((s) {
        final newStageId = 'stage_${_uuid.v4()}';
        stageIdMap[s.id] = newStageId;
        return s.copyWith(id: newStageId);
      }).toList();

      // Remap expense IDs & line items
      final expenseIdMap = <String, String>{};
      final newExpenses = parsedTrip.expenses.map((e) {
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
      final newScenarios = parsedTrip.scenarios.map((sc) {
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

      // Remap cash transactions with the NEW tripId and NEW expenseId
      final newTransactions = parsedTrip.cashTransactions.map((tx) {
        final mappedPayer = memberIdMap[tx.payerMemberId] ?? tx.payerMemberId;
        final mappedRecipient = memberIdMap[tx.recipient] ?? tx.recipient;
        final mappedExpId =
            tx.expenseId != null ? expenseIdMap[tx.expenseId] : null;

        return tx.copyWith(
          id: 'tx_${_uuid.v4()}',
          tripId: newTripId, // Explicitly point to the newly imported trip!
          expenseId: mappedExpId,
          payerMemberId: mappedPayer,
          recipient: mappedRecipient,
        );
      }).toList();

      final remappedTrip = Trip(
        id: newTripId,
        name: '${parsedTrip.name} (Bản sao nhập)',
        description: parsedTrip.description,
        treasurerId: memberIdMap[parsedTrip.treasurerId] ?? parsedTrip.treasurerId,
        members: newMembers,
        stages: newStages,
        expenses: newExpenses,
        scenarios: newScenarios,
        activeScenarioId: scenarioIdMap[parsedTrip.activeScenarioId] ??
            (newScenarios.isNotEmpty ? newScenarios.first.id : ''),
        isLedgerInitialized: parsedTrip.isLedgerInitialized,
        ledgerScenarioId: parsedTrip.ledgerScenarioId != null
            ? scenarioIdMap[parsedTrip.ledgerScenarioId]
            : null,
        cashTransactions: newTransactions,
        metadata: {
          ...parsedTrip.metadata,
          'importedAt': DateTime.now().toIso8601String(),
          'originalTripId': parsedTrip.id,
          'isSampleData': false,
        },
      );

      final saved = await repository.saveTrip(remappedTrip);
      importedTrips.add(saved);
    }

    return importedTrips;
  }

  @override
  Future<Trip> commitImport({
    required String jsonString,
    required TripRepository repository,
  }) async {
    final imported = await commitImportAll(
      jsonString: jsonString,
      repository: repository,
    );
    return imported.first;
  }
}
