import 'member.dart';
import 'stage.dart';
import 'expense.dart';
import 'scenario.dart';
import 'cash_transaction.dart';

class Trip {
  final String id;
  final String name;
  final String? description;
  final String treasurerId;
  final List<Member> members;
  final List<Stage> stages;
  final List<Expense> expenses;
  final List<Scenario> scenarios;
  final String activeScenarioId;
  final bool isLedgerInitialized;
  final String? ledgerScenarioId;
  final List<CashTransaction> cashTransactions;
  final Map<String, dynamic> metadata;

  const Trip({
    required this.id,
    required this.name,
    this.description,
    required this.treasurerId,
    this.members = const [],
    this.stages = const [],
    this.expenses = const [],
    this.scenarios = const [],
    required this.activeScenarioId,
    this.isLedgerInitialized = false,
    this.ledgerScenarioId,
    this.cashTransactions = const [],
    this.metadata = const {},
  });

  Member? getMember(String id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Member? get treasurer => getMember(treasurerId);

  Stage? getStage(String id) {
    try {
      return stages.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Expense? getExpense(String id) {
    try {
      return expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Scenario? get activeScenario {
    try {
      return scenarios.firstWhere((s) => s.id == activeScenarioId);
    } catch (_) {
      return scenarios.isNotEmpty ? scenarios.first : null;
    }
  }

  Scenario? get baselineScenario {
    try {
      return scenarios.firstWhere((s) => s.isBaseline);
    } catch (_) {
      return scenarios.isNotEmpty ? scenarios.first : null;
    }
  }

  int get revision => (metadata['revision'] as int?) ?? 1;

  /// Tiền mặt thực tế đang có trong quỹ:
  /// = Tổng tiền thành viên góp vào quỹ + hoàn cọc + NCC hoàn tiền - Tổng tiền quỹ đã chi trả/cọc/hoàn trả
  int get fundCashBalance {
    int balance = 0;
    for (final tx in cashTransactions) {
      if (tx.type == CashTransactionType.fundContribution ||
          tx.type == CashTransactionType.depositRefund ||
          tx.type == CashTransactionType.supplierRefund) {
        balance += tx.amount;
      } else if (tx.type.isPaidFromFund) {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  Trip copyWith({
    String? id,
    String? name,
    String? description,
    String? treasurerId,
    List<Member>? members,
    List<Stage>? stages,
    List<Expense>? expenses,
    List<Scenario>? scenarios,
    String? activeScenarioId,
    bool? isLedgerInitialized,
    String? ledgerScenarioId,
    List<CashTransaction>? cashTransactions,
    Map<String, dynamic>? metadata,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      treasurerId: treasurerId ?? this.treasurerId,
      members: members ?? this.members,
      stages: stages ?? this.stages,
      expenses: expenses ?? this.expenses,
      scenarios: scenarios ?? this.scenarios,
      activeScenarioId: activeScenarioId ?? this.activeScenarioId,
      isLedgerInitialized: isLedgerInitialized ?? this.isLedgerInitialized,
      ledgerScenarioId: ledgerScenarioId ?? this.ledgerScenarioId,
      cashTransactions: cashTransactions ?? this.cashTransactions,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'treasurerId': treasurerId,
        'members': members.map((e) => e.toJson()).toList(),
        'stages': stages.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'scenarios': scenarios.map((e) => e.toJson()).toList(),
        'activeScenarioId': activeScenarioId,
        'isLedgerInitialized': isLedgerInitialized,
        'ledgerScenarioId': ledgerScenarioId,
        'cashTransactions': cashTransactions.map((e) => e.toJson()).toList(),
        'metadata': metadata,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        treasurerId: json['treasurerId'] as String,
        members: (json['members'] as List<dynamic>?)
                ?.map((e) => Member.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        stages: (json['stages'] as List<dynamic>?)
                ?.map((e) => Stage.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        expenses: (json['expenses'] as List<dynamic>?)
                ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        scenarios: (json['scenarios'] as List<dynamic>?)
                ?.map((e) => Scenario.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        activeScenarioId: json['activeScenarioId'] as String? ?? 'scenario_1',
        isLedgerInitialized: json['isLedgerInitialized'] as bool? ?? false,
        ledgerScenarioId: json['ledgerScenarioId'] as String?,
        cashTransactions: (json['cashTransactions'] as List<dynamic>?)
                ?.map((e) => CashTransaction.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      );
}
