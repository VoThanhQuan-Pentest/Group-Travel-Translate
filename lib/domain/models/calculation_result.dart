class MemberExpenseBreakdown {
  final String memberId;
  final String expenseId;
  final String expenseTitle;
  final int baseAmount; // Tiền món hoặc phần chia cố định
  final int shippingShare; // Phần ship được phân bổ
  final int discountShare; // Phần giảm giá được trừ
  final int finalShare; // Số tiền cuối cùng phải chịu
  final String explanationNotes; // Giải thích chi tiết phục vụ drill-down

  const MemberExpenseBreakdown({
    required this.memberId,
    required this.expenseId,
    required this.expenseTitle,
    required this.baseAmount,
    this.shippingShare = 0,
    this.discountShare = 0,
    required this.finalShare,
    required this.explanationNotes,
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'expenseId': expenseId,
        'expenseTitle': expenseTitle,
        'baseAmount': baseAmount,
        'shippingShare': shippingShare,
        'discountShare': discountShare,
        'finalShare': finalShare,
        'explanationNotes': explanationNotes,
      };

  factory MemberExpenseBreakdown.fromJson(Map<String, dynamic> json) =>
      MemberExpenseBreakdown(
        memberId: json['memberId'] as String,
        expenseId: json['expenseId'] as String,
        expenseTitle: json['expenseTitle'] as String,
        baseAmount: json['baseAmount'] as int,
        shippingShare: json['shippingShare'] as int? ?? 0,
        discountShare: json['discountShare'] as int? ?? 0,
        finalShare: json['finalShare'] as int,
        explanationNotes: json['explanationNotes'] as String,
      );
}

class MemberCostSummary {
  final String memberId;
  final int totalCost;
  final List<MemberExpenseBreakdown> breakdowns;

  const MemberCostSummary({
    required this.memberId,
    required this.totalCost,
    this.breakdowns = const [],
  });

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'totalCost': totalCost,
        'breakdowns': breakdowns.map((e) => e.toJson()).toList(),
      };

  factory MemberCostSummary.fromJson(Map<String, dynamic> json) =>
      MemberCostSummary(
        memberId: json['memberId'] as String,
        totalCost: json['totalCost'] as int,
        breakdowns: (json['breakdowns'] as List<dynamic>?)
                ?.map((e) =>
                    MemberExpenseBreakdown.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

class ScenarioCalculationResult {
  final String scenarioId;
  final String scenarioName;
  final bool isStale;
  final int totalTripCost;
  final Map<String, MemberCostSummary> memberSummaries;
  final Map<String, int> stageSummaries;

  const ScenarioCalculationResult({
    required this.scenarioId,
    required this.scenarioName,
    this.isStale = false,
    required this.totalTripCost,
    required this.memberSummaries,
    required this.stageSummaries,
  });

  int getMemberCost(String memberId) =>
      memberSummaries[memberId]?.totalCost ?? 0;

  List<MemberExpenseBreakdown> getMemberBreakdowns(String memberId) =>
      memberSummaries[memberId]?.breakdowns ?? const [];

  ScenarioCalculationResult copyWith({
    String? scenarioId,
    String? scenarioName,
    bool? isStale,
    int? totalTripCost,
    Map<String, MemberCostSummary>? memberSummaries,
    Map<String, int>? stageSummaries,
  }) {
    return ScenarioCalculationResult(
      scenarioId: scenarioId ?? this.scenarioId,
      scenarioName: scenarioName ?? this.scenarioName,
      isStale: isStale ?? this.isStale,
      totalTripCost: totalTripCost ?? this.totalTripCost,
      memberSummaries: memberSummaries ?? this.memberSummaries,
      stageSummaries: stageSummaries ?? this.stageSummaries,
    );
  }

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'scenarioName': scenarioName,
        'isStale': isStale,
        'totalTripCost': totalTripCost,
        'memberSummaries':
            memberSummaries.map((k, v) => MapEntry(k, v.toJson())),
        'stageSummaries': stageSummaries,
      };

  factory ScenarioCalculationResult.fromJson(Map<String, dynamic> json) =>
      ScenarioCalculationResult(
        scenarioId: json['scenarioId'] as String,
        scenarioName: json['scenarioName'] as String,
        isStale: json['isStale'] as bool? ?? false,
        totalTripCost: json['totalTripCost'] as int,
        memberSummaries:
            (json['memberSummaries'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(
              k, MemberCostSummary.fromJson(v as Map<String, dynamic>)),
        ),
        stageSummaries:
            (json['stageSummaries'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as int),
        ),
      );
}

class ScenarioComparison {
  final String baselineScenarioId;
  final String targetScenarioId;
  final int tripDifference; // target - baseline
  final Map<String, int> memberDifferences; // target - baseline
  final Map<String, int> stageDifferences; // target - baseline

  const ScenarioComparison({
    required this.baselineScenarioId,
    required this.targetScenarioId,
    required this.tripDifference,
    required this.memberDifferences,
    required this.stageDifferences,
  });
}
