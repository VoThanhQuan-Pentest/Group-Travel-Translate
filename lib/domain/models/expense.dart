enum ExpenseCalcMode {
  fixedEqual, // 1. Tổng cố định - Chia đều
  fixedStageRatio, // 2. Tổng cố định - Chia theo tỷ lệ số chặng tính phí
  perPersonUnitPrice, // 3. Đơn giá theo đầu người
  itemized, // 4. Theo từng món
}

extension ExpenseCalcModeExt on ExpenseCalcMode {
  String get displayName {
    switch (this) {
      case ExpenseCalcMode.fixedEqual:
        return 'Cố định chia đều';
      case ExpenseCalcMode.fixedStageRatio:
        return 'Chia theo tỷ lệ số chặng';
      case ExpenseCalcMode.perPersonUnitPrice:
        return 'Đơn giá / người';
      case ExpenseCalcMode.itemized:
        return 'Theo từng món';
    }
  }

  String get description {
    switch (this) {
      case ExpenseCalcMode.fixedEqual:
        return 'Tổng chi phí chia đều cho các thành viên chịu tiền';
      case ExpenseCalcMode.fixedStageRatio:
        return 'Chia tổng tiền theo tỷ lệ số chặng mỗi người tham gia';
      case ExpenseCalcMode.perPersonUnitPrice:
        return 'Đơn giá nhân với số lượng người chịu tiền';
      case ExpenseCalcMode.itemized:
        return 'Tính theo các món cá nhân đặt kèm phân bổ ship/giảm giá';
    }
  }
}

enum CostBearerStatus {
  inherited, // Kế thừa từ chặng (mặc định)
  manualInclude, // Chọn thủ công (ép chịu dù vắng mặt)
  manualExclude, // Bỏ thủ công (miễn chịu dù có mặt)
}

extension CostBearerStatusExt on CostBearerStatus {
  String get displayName {
    switch (this) {
      case CostBearerStatus.inherited:
        return 'Kế thừa';
      case CostBearerStatus.manualInclude:
        return 'Chọn thủ công';
      case CostBearerStatus.manualExclude:
        return 'Bỏ thủ công';
    }
  }

  bool isEffectiveBearer(bool isPresentInStage) {
    switch (this) {
      case CostBearerStatus.inherited:
        return isPresentInStage;
      case CostBearerStatus.manualInclude:
        return true;
      case CostBearerStatus.manualExclude:
        return false;
    }
  }
}

enum ModifierAllocationRule {
  equalSplit, // Chia đều
  proportionalToSubtotal, // Chia theo tỷ lệ tiền món
}

extension ModifierAllocationRuleExt on ModifierAllocationRule {
  String get displayName {
    switch (this) {
      case ModifierAllocationRule.equalSplit:
        return 'Chia đều cho người mua';
      case ModifierAllocationRule.proportionalToSubtotal:
        return 'Chia theo tỷ lệ tiền món';
    }
  }
}

class LineItem {
  final String id;
  final String name;
  final int quantity;
  final int unitPrice;
  final String bearerMemberId;

  const LineItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.unitPrice,
    required this.bearerMemberId,
  });

  int get subtotal => quantity * unitPrice;

  LineItem copyWith({
    String? id,
    String? name,
    int? quantity,
    int? unitPrice,
    String? bearerMemberId,
  }) {
    return LineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      bearerMemberId: bearerMemberId ?? this.bearerMemberId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'bearerMemberId': bearerMemberId,
      };

  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: json['unitPrice'] as int,
        bearerMemberId: json['bearerMemberId'] as String,
      );
}

class Expense {
  final String id;
  final String stageId;
  final List<String> stageIds; // Cho trường hợp fixedStageRatio gắn nhiều chặng
  final String title;
  final String? description;
  final ExpenseCalcMode calcMode;
  final int estimatedTotal; // Giá cố định dự toán (nếu fixedEqual hoặc fixedStageRatio)
  final int unitPrice; // Đơn giá nếu perPersonUnitPrice
  final List<LineItem> lineItems;
  final int shippingFee;
  final int discountFee;
  final ModifierAllocationRule shippingRule;
  final ModifierAllocationRule discountRule;
  final bool isCommitted; // Khoản chi đã cam kết (không tự miễn khi nghỉ)
  final Map<String, CostBearerStatus> costBearers; // memberId -> status
  final int? actualPrice; // null = Chưa nhập, 0 = Không phát sinh, >0 = Thực tế

  const Expense({
    required this.id,
    required this.stageId,
    this.stageIds = const [],
    required this.title,
    this.description,
    required this.calcMode,
    this.estimatedTotal = 0,
    this.unitPrice = 0,
    this.lineItems = const [],
    this.shippingFee = 0,
    this.discountFee = 0,
    this.shippingRule = ModifierAllocationRule.equalSplit,
    this.discountRule = ModifierAllocationRule.proportionalToSubtotal,
    this.isCommitted = false,
    this.costBearers = const {},
    this.actualPrice,
  });

  /// Trả về trạng thái người chịu tiền của [memberId].
  /// Nếu chưa có trong map, mặc định là [CostBearerStatus.inherited].
  CostBearerStatus getBearerStatus(String memberId) {
    return costBearers[memberId] ?? CostBearerStatus.inherited;
  }

  Expense copyWith({
    String? id,
    String? stageId,
    List<String>? stageIds,
    String? title,
    String? description,
    ExpenseCalcMode? calcMode,
    int? estimatedTotal,
    int? unitPrice,
    List<LineItem>? lineItems,
    int? shippingFee,
    int? discountFee,
    ModifierAllocationRule? shippingRule,
    ModifierAllocationRule? discountRule,
    bool? isCommitted,
    Map<String, CostBearerStatus>? costBearers,
    int? actualPrice,
    bool clearActualPrice = false,
  }) {
    return Expense(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      stageIds: stageIds ?? this.stageIds,
      title: title ?? this.title,
      description: description ?? this.description,
      calcMode: calcMode ?? this.calcMode,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      unitPrice: unitPrice ?? this.unitPrice,
      lineItems: lineItems ?? this.lineItems,
      shippingFee: shippingFee ?? this.shippingFee,
      discountFee: discountFee ?? this.discountFee,
      shippingRule: shippingRule ?? this.shippingRule,
      discountRule: discountRule ?? this.discountRule,
      isCommitted: isCommitted ?? this.isCommitted,
      costBearers: costBearers ?? this.costBearers,
      actualPrice: clearActualPrice ? null : (actualPrice ?? this.actualPrice),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stageId': stageId,
        'stageIds': stageIds,
        'title': title,
        'description': description,
        'calcMode': calcMode.name,
        'estimatedTotal': estimatedTotal,
        'unitPrice': unitPrice,
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
        'shippingFee': shippingFee,
        'discountFee': discountFee,
        'shippingRule': shippingRule.name,
        'discountRule': discountRule.name,
        'isCommitted': isCommitted,
        'costBearers': costBearers.map((k, v) => MapEntry(k, v.name)),
        'actualPrice': actualPrice,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        stageId: json['stageId'] as String,
        stageIds: (json['stageIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        title: json['title'] as String,
        description: json['description'] as String?,
        calcMode: ExpenseCalcMode.values.firstWhere(
          (e) => e.name == json['calcMode'],
          orElse: () => ExpenseCalcMode.fixedEqual,
        ),
        estimatedTotal: json['estimatedTotal'] as int? ?? 0,
        unitPrice: json['unitPrice'] as int? ?? 0,
        lineItems: (json['lineItems'] as List<dynamic>?)
                ?.map((e) => LineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        shippingFee: json['shippingFee'] as int? ?? 0,
        discountFee: json['discountFee'] as int? ?? 0,
        shippingRule: ModifierAllocationRule.values.firstWhere(
          (e) => e.name == json['shippingRule'],
          orElse: () => ModifierAllocationRule.equalSplit,
        ),
        discountRule: ModifierAllocationRule.values.firstWhere(
          (e) => e.name == json['discountRule'],
          orElse: () => ModifierAllocationRule.proportionalToSubtotal,
        ),
        isCommitted: json['isCommitted'] as bool? ?? false,
        costBearers: (json['costBearers'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(
                k,
                CostBearerStatus.values.firstWhere((e) => e.name == v,
                    orElse: () => CostBearerStatus.inherited),
              ),
            ) ??
            const {},
        actualPrice: json['actualPrice'] as int?,
      );
}
