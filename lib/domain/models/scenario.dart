import 'expense.dart';

class Scenario {
  final String id;
  final String name;
  final String? description;
  final bool isBaseline;

  /// Bản đồ điểm danh: stageId -> Tập hợp memberId có mặt ở chặng đó
  final Map<String, Set<String>> stageAttendances;

  /// Bản đồ ghi đè người chịu tiền riêng cho kịch bản:
  /// expenseId -> (memberId -> CostBearerStatus)
  final Map<String, Map<String, CostBearerStatus>> costBearerOverrides;

  /// Bản đồ ghi đè giá/phí riêng cho kịch bản:
  /// expenseId -> giá ghi đè
  final Map<String, int> expenseAmountOverrides;

  /// Đánh dấu trạng thái tính toán: nếu người dùng chỉnh sửa đầu vào làm thay đổi dữ liệu,
  /// cờ này được bật để hiển thị cảnh báo "Chưa có kết quả tính toán mới / Kết quả cũ đã hết hiệu lực"
  final bool isStale;

  const Scenario({
    required this.id,
    required this.name,
    this.description,
    this.isBaseline = false,
    this.stageAttendances = const {},
    this.costBearerOverrides = const {},
    this.expenseAmountOverrides = const {},
    this.isStale = false,
  });

  bool isMemberPresentInStage(String stageId, String memberId) {
    return stageAttendances[stageId]?.contains(memberId) ?? false;
  }

  CostBearerStatus getEffectiveBearerStatus(
    Expense expense,
    String memberId,
  ) {
    // Ưu tiên override trong kịch bản trước
    if (costBearerOverrides.containsKey(expense.id) &&
        costBearerOverrides[expense.id]!.containsKey(memberId)) {
      return costBearerOverrides[expense.id]![memberId]!;
    }
    // Sau đó lấy từ expense
    return expense.getBearerStatus(memberId);
  }

  bool isMemberCostBearer(Expense expense, String memberId) {
    final status = getEffectiveBearerStatus(expense, memberId);
    final isPresent = isMemberPresentInStage(expense.stageId, memberId);
    return status.isEffectiveBearer(isPresent);
  }

  Scenario copyWith({
    String? id,
    String? name,
    String? description,
    bool? isBaseline,
    Map<String, Set<String>>? stageAttendances,
    Map<String, Map<String, CostBearerStatus>>? costBearerOverrides,
    Map<String, int>? expenseAmountOverrides,
    bool? isStale,
  }) {
    return Scenario(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isBaseline: isBaseline ?? this.isBaseline,
      stageAttendances: stageAttendances ?? this.stageAttendances,
      costBearerOverrides: costBearerOverrides ?? this.costBearerOverrides,
      expenseAmountOverrides: expenseAmountOverrides ?? this.expenseAmountOverrides,
      isStale: isStale ?? this.isStale,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'isBaseline': isBaseline,
        'stageAttendances': stageAttendances.map(
          (k, v) => MapEntry(k, v.toList()),
        ),
        'costBearerOverrides': costBearerOverrides.map(
          (expId, map) => MapEntry(
            expId,
            map.map((mId, status) => MapEntry(mId, status.name)),
          ),
        ),
        'expenseAmountOverrides': expenseAmountOverrides,
        'isStale': isStale,
      };

  factory Scenario.fromJson(Map<String, dynamic> json) => Scenario(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        isBaseline: json['isBaseline'] as bool? ?? false,
        stageAttendances: (json['stageAttendances'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as List<dynamic>).map((e) => e as String).toSet()),
            ) ??
            const {},
        costBearerOverrides: (json['costBearerOverrides'] as Map<String, dynamic>?)?.map(
              (expId, map) => MapEntry(
                expId,
                (map as Map<String, dynamic>).map(
                  (mId, s) => MapEntry(
                    mId,
                    CostBearerStatus.values.firstWhere(
                      (e) => e.name == s,
                      orElse: () => CostBearerStatus.inherited,
                    ),
                  ),
                ),
              ),
            ) ??
            const {},
        expenseAmountOverrides: (json['expenseAmountOverrides'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            const {},
        isStale: json['isStale'] as bool? ?? false,
      );
}
