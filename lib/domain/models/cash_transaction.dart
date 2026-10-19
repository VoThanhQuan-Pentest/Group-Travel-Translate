enum CashTransactionType {
  fundContribution, // Góp quỹ (Thành viên -> Quỹ)
  outOfPocketPayment, // Cá nhân ứng tiền trả hộ (Thành viên -> Nhà cung cấp / Hóa đơn)
  supplierPayment, // Trả nhà cung cấp (Quỹ -> Nhà cung cấp / Hóa đơn)
  supplierDeposit, // Đặt cọc (Quỹ -> Nhà cung cấp / Hóa đơn)
  refund, // Hoàn tiền (Quỹ -> Thành viên)
  depositOffset, // Đối trừ cọc vào hóa đơn
  depositRefund, // Hoàn cọc (Nhà cung cấp -> Quỹ)
  lostDeposit, // Mất cọc
  supplierRefund, // Nhà cung cấp hoàn tiền
  memberTransfer, // Chuyển tiền giữa thành viên
}

extension CashTransactionTypeExt on CashTransactionType {
  String get displayName {
    switch (this) {
      case CashTransactionType.fundContribution:
        return 'Góp quỹ';
      case CashTransactionType.outOfPocketPayment:
        return 'Cá nhân ứng tiền';
      case CashTransactionType.supplierPayment:
        return 'Thanh toán hóa đơn';
      case CashTransactionType.supplierDeposit:
        return 'Đặt cọc';
      case CashTransactionType.refund:
        return 'Hoàn tiền';
      case CashTransactionType.depositOffset:
        return 'Đối trừ cọc';
      case CashTransactionType.depositRefund:
        return 'Hoàn cọc';
      case CashTransactionType.lostDeposit:
        return 'Mất cọc';
      case CashTransactionType.supplierRefund:
        return 'NCC hoàn tiền';
      case CashTransactionType.memberTransfer:
        return 'Chuyển tiền thành viên';
    }
  }

  bool get isPayerMember =>
      this == CashTransactionType.fundContribution ||
      this == CashTransactionType.outOfPocketPayment ||
      this == CashTransactionType.memberTransfer;

  bool get isPaidFromFund =>
      this == CashTransactionType.supplierPayment ||
      this == CashTransactionType.supplierDeposit ||
      this == CashTransactionType.refund;
}

class CashTransaction {
  final String id;
  final String tripId;
  final String? expenseId; // Gắn với hóa đơn nếu có
  final CashTransactionType type;
  final String payerMemberId; // ID thành viên (hoặc 'fund' nếu là quỹ)
  final String recipient; // Tên nhà cung cấp hoặc ID thành viên nhận
  final int amount; // Số tiền nguyên VNĐ
  final String note;
  final DateTime timestamp;
  final String? businessKey; // Khóa nghiệp vụ duy nhất chống ghi trùng

  const CashTransaction({
    required this.id,
    required this.tripId,
    this.expenseId,
    required this.type,
    required this.payerMemberId,
    required this.recipient,
    required this.amount,
    required this.note,
    required this.timestamp,
    this.businessKey,
  });

  CashTransaction copyWith({
    String? id,
    String? tripId,
    String? expenseId,
    CashTransactionType? type,
    String? payerMemberId,
    String? recipient,
    int? amount,
    String? note,
    DateTime? timestamp,
    String? businessKey,
  }) {
    return CashTransaction(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      expenseId: expenseId ?? this.expenseId,
      type: type ?? this.type,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      businessKey: businessKey ?? this.businessKey,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'expenseId': expenseId,
        'type': type.name,
        'payerMemberId': payerMemberId,
        'recipient': recipient,
        'amount': amount,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
        'businessKey': businessKey,
      };

  factory CashTransaction.fromJson(Map<String, dynamic> json) => CashTransaction(
        id: json['id'] as String,
        tripId: json['tripId'] as String,
        expenseId: json['expenseId'] as String?,
        type: CashTransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CashTransactionType.fundContribution,
        ),
        payerMemberId: json['payerMemberId'] as String,
        recipient: json['recipient'] as String,
        amount: json['amount'] as int,
        note: json['note'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        businessKey: json['businessKey'] as String?,
      );
}
