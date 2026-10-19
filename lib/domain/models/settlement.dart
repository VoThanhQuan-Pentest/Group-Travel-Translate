enum SettlementMethod {
  viaFund, // Quyết toán qua Quỹ
  directTransfer, // Chuyển khoản chéo trực tiếp (Gợi ý chuyển khoản gọn)
}

extension SettlementMethodExt on SettlementMethod {
  String get displayName {
    switch (this) {
      case SettlementMethod.viaFund:
        return 'Quyết toán qua Quỹ';
      case SettlementMethod.directTransfer:
        return 'Gợi ý chuyển khoản gọn (Chuyển chéo)';
    }
  }

  String get description {
    switch (this) {
      case SettlementMethod.viaFund:
        return 'Người thiếu đóng vào Quỹ cho Thủ quỹ, Thủ quỹ trả lại cho người thừa từ Quỹ.';
      case SettlementMethod.directTransfer:
        return 'Thuật toán kết hợp các giao dịch chuyển khoản trực tiếp giữa các thành viên để giảm số lần chuyển.';
    }
  }
}

enum TransferStatus {
  pending, // Đang xử lý
  completed, // Đã chuyển
}

extension TransferStatusExt on TransferStatus {
  String get displayName {
    switch (this) {
      case TransferStatus.pending:
        return 'Đang xử lý';
      case TransferStatus.completed:
        return 'Đã chuyển';
    }
  }
}

class MemberDebtSummary {
  final String memberId;
  final String memberName;
  final int costObligation; // Phần phải chịu
  final int fundContributed; // Đã góp quỹ
  final int outOfPocketPaid; // Đã ứng trả hộ
  final int refunded; // Đã nhận lại (nếu có hoàn trả trước)

  const MemberDebtSummary({
    required this.memberId,
    required this.memberName,
    required this.costObligation,
    required this.fundContributed,
    required this.outOfPocketPaid,
    this.refunded = 0,
  });

  /// Tổng số tiền thực tế thành viên đã bỏ ra
  int get totalPaid => fundContributed + outOfPocketPaid - refunded;

  /// Số dư ròng:
  /// Dương (>0): Được nhận về
  /// Âm (<0): Còn phải đóng thêm
  /// 0: Đã cân bằng hoàn toàn
  int get netBalance => totalPaid - costObligation;

  bool get needsToPay => netBalance < 0;
  bool get getsRefund => netBalance > 0;
  int get amountToPay => needsToPay ? -netBalance : 0;
  int get amountToReceive => getsRefund ? netBalance : 0;

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'costObligation': costObligation,
        'fundContributed': fundContributed,
        'outOfPocketPaid': outOfPocketPaid,
        'refunded': refunded,
        'netBalance': netBalance,
      };

  factory MemberDebtSummary.fromJson(Map<String, dynamic> json) =>
      MemberDebtSummary(
        memberId: json['memberId'] as String,
        memberName: json['memberName'] as String,
        costObligation: json['costObligation'] as int,
        fundContributed: json['fundContributed'] as int,
        outOfPocketPaid: json['outOfPocketPaid'] as int,
        refunded: json['refunded'] as int? ?? 0,
      );
}

class SettlementTransferStep {
  final String id;
  final String fromMemberId;
  final String toMemberId;
  final String fromMemberName;
  final String toMemberName;
  final int amount;
  final TransferStatus status;
  final bool isViaFund;

  const SettlementTransferStep({
    required this.id,
    required this.fromMemberId,
    required this.toMemberId,
    required this.fromMemberName,
    required this.toMemberName,
    required this.amount,
    this.status = TransferStatus.pending,
    this.isViaFund = false,
  });

  SettlementTransferStep copyWith({
    String? id,
    String? fromMemberId,
    String? toMemberId,
    String? fromMemberName,
    String? toMemberName,
    int? amount,
    TransferStatus? status,
    bool? isViaFund,
  }) {
    return SettlementTransferStep(
      id: id ?? this.id,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      fromMemberName: fromMemberName ?? this.fromMemberName,
      toMemberName: toMemberName ?? this.toMemberName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      isViaFund: isViaFund ?? this.isViaFund,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromMemberId': fromMemberId,
        'toMemberId': toMemberId,
        'fromMemberName': fromMemberName,
        'toMemberName': toMemberName,
        'amount': amount,
        'status': status.name,
        'isViaFund': isViaFund,
      };

  factory SettlementTransferStep.fromJson(Map<String, dynamic> json) =>
      SettlementTransferStep(
        id: json['id'] as String,
        fromMemberId: json['fromMemberId'] as String,
        toMemberId: json['toMemberId'] as String,
        fromMemberName: json['fromMemberName'] as String,
        toMemberName: json['toMemberName'] as String,
        amount: json['amount'] as int,
        status: TransferStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransferStatus.pending,
        ),
        isViaFund: json['isViaFund'] as bool? ?? false,
      );
}

class SettlementValidation {
  final bool canSettle;
  final List<String> blockingReasons;

  const SettlementValidation({
    required this.canSettle,
    this.blockingReasons = const [],
  });

  static const SettlementValidation valid =
      SettlementValidation(canSettle: true);
}

class SettlementResult {
  final SettlementValidation validation;
  final SettlementMethod method;
  final List<MemberDebtSummary> debtSummaries;
  final List<SettlementTransferStep> transferSteps;
  final int fundCashOnHand; // Lượng tiền mặt thực tế Thủ quỹ đang cầm trong quỹ

  const SettlementResult({
    required this.validation,
    required this.method,
    required this.debtSummaries,
    required this.transferSteps,
    required this.fundCashOnHand,
  });
}
