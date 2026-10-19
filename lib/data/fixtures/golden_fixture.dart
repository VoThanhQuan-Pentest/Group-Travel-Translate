import '../../domain/models/member.dart';
import '../../domain/models/stage.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/cash_transaction.dart';
import '../../domain/models/trip.dart';

class GoldenFixture {
  GoldenFixture._();

  static const String tripId = 'golden_trip_dalat';

  // 4 Thành viên theo thứ tự ưu tiên xử lý đồng lẻ: An, Bình, Chi, Dũng
  static const Member memberAn = Member(id: 'm_an', name: 'An', isTreasurer: true);
  static const Member memberBinh = Member(id: 'm_binh', name: 'Bình');
  static const Member memberChi = Member(id: 'm_chi', name: 'Chi');
  static const Member memberDung = Member(id: 'm_dung', name: 'Dũng');

  static List<Member> get members => [memberAn, memberBinh, memberChi, memberDung];

  // Các chặng
  static const Stage stage1 = Stage(
    id: 'stage_1',
    name: 'Buổi sáng & Trưa',
    order: 1,
    description: 'Di chuyển bằng xe và ăn trưa cả đoàn',
  );

  static const Stage stage2 = Stage(
    id: 'stage_2',
    name: 'Buổi chiều',
    order: 2,
    description: 'Tham quan thắng cảnh và uống trà sữa chiều',
  );

  static List<Stage> get stages => [stage1, stage2];

  // 4 Khoản chi mẫu
  // 1. Xe (Đã cam kết): 400.000đ, chia đều 4 người (100.000đ/người), cam kết không miễn khi nghỉ
  static const Expense expenseCar = Expense(
    id: 'exp_car',
    stageId: 'stage_1',
    stageIds: ['stage_1', 'stage_2'],
    title: 'Xe di chuyển (Cam kết)',
    description: 'Thuê xe trọn gói cho chuyến đi, chi phí cam kết chia đều',
    calcMode: ExpenseCalcMode.fixedEqual,
    estimatedTotal: 400000,
    isCommitted: true,
    costBearers: {
      'm_an': CostBearerStatus.manualInclude,
      'm_binh': CostBearerStatus.manualInclude,
      'm_chi': CostBearerStatus.manualInclude,
      'm_dung': CostBearerStatus.manualInclude,
    },
    actualPrice: 400000,
  );

  // 2. Ăn trưa: 60.000đ / người có mặt
  static const Expense expenseLunch = Expense(
    id: 'exp_lunch',
    stageId: 'stage_1',
    title: 'Ăn trưa',
    description: 'Cơm trưa thanh toán theo đầu người có mặt',
    calcMode: ExpenseCalcMode.perPersonUnitPrice,
    unitPrice: 60000,
    isCommitted: false,
    costBearers: {
      'm_an': CostBearerStatus.inherited,
      'm_binh': CostBearerStatus.inherited,
      'm_chi': CostBearerStatus.inherited,
      'm_dung': CostBearerStatus.inherited,
    },
    actualPrice: 180000, // Ở kịch bản 4: 3 người có mặt = 180.000đ
  );

  // 3. Vé tham quan chiều: 80.000đ / người có mặt
  static const Expense expenseTicket = Expense(
    id: 'exp_ticket',
    stageId: 'stage_2',
    title: 'Vé tham quan chiều',
    description: 'Vé vào cổng khu du lịch theo đầu người có mặt buổi chiều',
    calcMode: ExpenseCalcMode.perPersonUnitPrice,
    unitPrice: 80000,
    isCommitted: false,
    costBearers: {
      'm_an': CostBearerStatus.inherited,
      'm_binh': CostBearerStatus.inherited,
      'm_chi': CostBearerStatus.inherited,
      'm_dung': CostBearerStatus.inherited,
    },
    actualPrice: 160000, // Ở kịch bản 4: 2 người có mặt = 160.000đ
  );

  // 4. Trà sữa chiều: Theo từng món (An 30k, Bình 40k, Chi 50k, Dũng 60k; Ship 20k chia đều; Giảm 10k theo tỷ lệ món)
  static const Expense expenseMilkTea = Expense(
    id: 'exp_milktea',
    stageId: 'stage_2',
    title: 'Trà sữa chiều (Theo món)',
    description: 'Đặt món trà sữa theo yêu cầu riêng từng người',
    calcMode: ExpenseCalcMode.itemized,
    lineItems: [
      LineItem(
        id: 'item_an',
        name: 'Trà ô long sữa (An)',
        quantity: 1,
        unitPrice: 30000,
        bearerMemberId: 'm_an',
      ),
      LineItem(
        id: 'item_binh',
        name: 'Trà đào cam sả (Bình)',
        quantity: 1,
        unitPrice: 40000,
        bearerMemberId: 'm_binh',
      ),
      LineItem(
        id: 'item_chi',
        name: 'Trà sữa trân châu đường đen (Chi)',
        quantity: 1,
        unitPrice: 50000,
        bearerMemberId: 'm_chi',
      ),
      LineItem(
        id: 'item_dung',
        name: 'Matcha macchiato đậu đỏ (Dũng)',
        quantity: 1,
        unitPrice: 60000,
        bearerMemberId: 'm_dung',
      ),
    ],
    shippingFee: 20000,
    discountFee: 10000,
    shippingRule: ModifierAllocationRule.equalSplit,
    discountRule: ModifierAllocationRule.proportionalToSubtotal,
    isCommitted: false,
    costBearers: {
      'm_an': CostBearerStatus.inherited,
      'm_binh': CostBearerStatus.inherited,
      'm_chi': CostBearerStatus.inherited,
      'm_dung': CostBearerStatus.inherited,
    },
    actualPrice: 80000, // Ở kịch bản 4: Món An+Bình (70k) + ship (20k) - giảm (10k) = 80.000đ
  );

  static List<Expense> get expenses => [
        expenseCar,
        expenseLunch,
        expenseTicket,
        expenseMilkTea,
      ];

  // 4 Kịch bản chuẩn đối chiếu (Golden Scenarios)
  // 1. Đi đủ
  static const Scenario scenario1 = Scenario(
    id: 'scenario_1',
    name: '1. Đi đủ',
    description: 'Tất cả 4 thành viên tham gia trọn vẹn cả 2 chặng',
    isBaseline: true,
    stageAttendances: {
      'stage_1': {'m_an', 'm_binh', 'm_chi', 'm_dung'},
      'stage_2': {'m_an', 'm_binh', 'm_chi', 'm_dung'},
    },
  );

  // 2. Dũng nghỉ, vẫn chịu xe
  static const Scenario scenario2 = Scenario(
    id: 'scenario_2',
    name: '2. Dũng nghỉ, vẫn chịu xe',
    description: 'Dũng bận việc nghỉ cả ngày, vẫn chịu chi phí xe đã cam kết',
    isBaseline: false,
    stageAttendances: {
      'stage_1': {'m_an', 'm_binh', 'm_chi'},
      'stage_2': {'m_an', 'm_binh', 'm_chi'},
    },
  );

  // 3. Chi về sau trưa
  static const Scenario scenario3 = Scenario(
    id: 'scenario_3',
    name: '3. Chi về sau trưa',
    description: 'Chi tham gia buổi sáng và ăn trưa, buổi chiều về sớm',
    isBaseline: false,
    stageAttendances: {
      'stage_1': {'m_an', 'm_binh', 'm_chi', 'm_dung'},
      'stage_2': {'m_an', 'm_binh', 'm_dung'},
    },
  );

  // 4. Dũng nghỉ + Chi về sớm
  static const Scenario scenario4 = Scenario(
    id: 'scenario_4',
    name: '4. Dũng nghỉ + Chi về sớm',
    description: 'Dũng nghỉ cả chuyến, Chi tham gia trưa rồi về sớm buổi chiều',
    isBaseline: false,
    stageAttendances: {
      'stage_1': {'m_an', 'm_binh', 'm_chi'},
      'stage_2': {'m_an', 'm_binh'},
    },
  );

  static List<Scenario> get scenarios => [
        scenario1,
        scenario2,
        scenario3,
        scenario4,
      ];

  // Giao dịch dòng tiền chuẩn cho Kịch bản 4:
  // - 4 người góp quỹ: 200.000đ/người (Thu quỹ = 800.000đ)
  // - An ứng tiền túi trả hộ: 240.000đ
  // - Quỹ chi trả nhà cung cấp: 580.000đ
  // => Tồn quỹ hiện tại: 220.000đ
  static List<CashTransaction> get goldenCashTransactions => [
        CashTransaction(
          id: 'tx_fund_an',
          tripId: tripId,
          type: CashTransactionType.fundContribution,
          payerMemberId: 'm_an',
          recipient: 'Quỹ chung',
          amount: 200000,
          note: 'An góp quỹ đầu chuyến',
          timestamp: DateTime(2026, 10, 19, 8, 0),
        ),
        CashTransaction(
          id: 'tx_fund_binh',
          tripId: tripId,
          type: CashTransactionType.fundContribution,
          payerMemberId: 'm_binh',
          recipient: 'Quỹ chung',
          amount: 200000,
          note: 'Bình góp quỹ đầu chuyến',
          timestamp: DateTime(2026, 10, 19, 8, 5),
        ),
        CashTransaction(
          id: 'tx_fund_chi',
          tripId: tripId,
          type: CashTransactionType.fundContribution,
          payerMemberId: 'm_chi',
          recipient: 'Quỹ chung',
          amount: 200000,
          note: 'Chi góp quỹ đầu chuyến',
          timestamp: DateTime(2026, 10, 19, 8, 10),
        ),
        CashTransaction(
          id: 'tx_fund_dung',
          tripId: tripId,
          type: CashTransactionType.fundContribution,
          payerMemberId: 'm_dung',
          recipient: 'Quỹ chung',
          amount: 200000,
          note: 'Dũng góp quỹ đầu chuyến',
          timestamp: DateTime(2026, 10, 19, 8, 15),
        ),
        CashTransaction(
          id: 'tx_an_out_of_pocket',
          tripId: tripId,
          expenseId: 'exp_lunch',
          type: CashTransactionType.outOfPocketPayment,
          payerMemberId: 'm_an',
          recipient: 'Nhà hàng Cơm Niêu',
          amount: 240000,
          note: 'An rút ví cá nhân trả hộ tiền ăn trưa và nước uống',
          timestamp: DateTime(2026, 10, 19, 12, 30),
        ),
        CashTransaction(
          id: 'tx_fund_pay_car',
          tripId: tripId,
          expenseId: 'exp_car',
          type: CashTransactionType.supplierPayment,
          payerMemberId: 'fund',
          recipient: 'Nhà xe du lịch Phương Trang',
          amount: 400000,
          note: 'Quỹ chi trả tiền thuê xe trọn gói',
          timestamp: DateTime(2026, 10, 19, 9, 0),
        ),
        CashTransaction(
          id: 'tx_fund_pay_tickets',
          tripId: tripId,
          expenseId: 'exp_ticket',
          type: CashTransactionType.supplierPayment,
          payerMemberId: 'fund',
          recipient: 'Khu du lịch Thung Lũng Tình Yêu',
          amount: 100000,
          note: 'Quỹ chi trả một phần vé tham quan chiều',
          timestamp: DateTime(2026, 10, 19, 14, 0),
        ),
        CashTransaction(
          id: 'tx_fund_pay_milktea',
          tripId: tripId,
          expenseId: 'exp_milktea',
          type: CashTransactionType.supplierPayment,
          payerMemberId: 'fund',
          recipient: 'Quán Trà Sữa GongCha',
          amount: 80000,
          note: 'Quỹ thanh toán hóa đơn trà sữa chiều',
          timestamp: DateTime(2026, 10, 19, 16, 0),
        ),
      ];

  static Trip createGoldenTrip() {
    return Trip(
      id: tripId,
      name: 'Chuyến đi Đà Lạt 2 ngày 1 đêm (Bộ dữ liệu mẫu kiểm thử)',
      description: 'Chuyến du lịch dã ngoại nhóm 4 người tại Đà Lạt',
      treasurerId: 'm_an',
      members: members,
      stages: stages,
      expenses: expenses,
      scenarios: scenarios,
      activeScenarioId: 'scenario_4',
      isLedgerInitialized: true,
      ledgerScenarioId: 'scenario_4',
      cashTransactions: goldenCashTransactions,
      metadata: {
        'version': '1.0.0',
        'algorithmVersion': 'v1-greedy-fair-remainder',
        'isSampleData': true,
        'createdAt': '2026-10-19T08:00:00.000Z',
      },
    );
  }
}
