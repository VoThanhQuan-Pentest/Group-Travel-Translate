import '../../core/utils/currency_formatter.dart';
import '../models/trip.dart';
import '../models/scenario.dart';
import '../models/expense.dart';
import '../models/calculation_result.dart';
import '../models/settlement.dart';
import '../models/cash_transaction.dart';
import 'calculation_service.dart';

class RealCalculationService implements CalculationService {
  @override
  ScenarioCalculationResult calculateScenario({
    required Trip trip,
    required Scenario scenario,
  }) {
    return _doCalculate(
      trip: trip,
      scenario: scenario,
      isActual: false,
    );
  }

  @override
  ScenarioCalculationResult calculateActual({
    required Trip trip,
    required Scenario scenario,
  }) {
    return _doCalculate(
      trip: trip,
      scenario: scenario,
      isActual: true,
    );
  }

  ScenarioCalculationResult _doCalculate({
    required Trip trip,
    required Scenario scenario,
    required bool isActual,
  }) {
    final memberSummaries = <String, List<MemberExpenseBreakdown>>{
      for (final m in trip.members) m.id: [],
    };
    final stageSummaries = <String, int>{
      for (final s in trip.stages) s.id: 0,
    };
    int totalTripCost = 0;

    for (final expense in trip.expenses) {
      final breakdownMap = _calculateExpenseBreakdowns(
        trip: trip,
        scenario: scenario,
        expense: expense,
        isActual: isActual,
      );

      int expenseTotalInScenario = 0;
      for (final entry in breakdownMap.entries) {
        final mId = entry.key;
        final bd = entry.value;
        memberSummaries[mId]?.add(bd);
        expenseTotalInScenario += bd.finalShare;
      }

      totalTripCost += expenseTotalInScenario;

      // Add to stage summary
      if (expense.stageIds.isNotEmpty &&
          expense.calcMode == ExpenseCalcMode.fixedStageRatio) {
        // Distribute expense across its stages proportionally
        final perStage = expenseTotalInScenario ~/ expense.stageIds.length;
        var rem = expenseTotalInScenario % expense.stageIds.length;
        for (final sId in expense.stageIds) {
          int add = perStage + (rem > 0 ? 1 : 0);
          if (rem > 0) rem--;
          stageSummaries[sId] = (stageSummaries[sId] ?? 0) + add;
        }
      } else {
        stageSummaries[expense.stageId] =
            (stageSummaries[expense.stageId] ?? 0) + expenseTotalInScenario;
      }
    }

    final finalMemberSummaries = <String, MemberCostSummary>{};
    for (final member in trip.members) {
      final bds = memberSummaries[member.id] ?? [];
      final cost = bds.fold<int>(0, (sum, b) => sum + b.finalShare);
      finalMemberSummaries[member.id] = MemberCostSummary(
        memberId: member.id,
        totalCost: cost,
        breakdowns: bds,
      );
    }

    return ScenarioCalculationResult(
      scenarioId: scenario.id,
      scenarioName: scenario.name,
      isStale: scenario.isStale,
      totalTripCost: totalTripCost,
      memberSummaries: finalMemberSummaries,
      stageSummaries: stageSummaries,
    );
  }

  Map<String, MemberExpenseBreakdown> _calculateExpenseBreakdowns({
    required Trip trip,
    required Scenario scenario,
    required Expense expense,
    required bool isActual,
  }) {
    // If calculating in Actual mode:
    // If actualPrice is null (not entered), return 0 share or unentered flag
    if (isActual && expense.actualPrice == null) {
      return {
        for (final m in trip.members)
          m.id: MemberExpenseBreakdown(
            memberId: m.id,
            expenseId: expense.id,
            expenseTitle: expense.title,
            baseAmount: 0,
            finalShare: 0,
            explanationNotes: 'Chưa có hóa đơn thực tế',
          ),
      };
    }

    // Determine target total or prices
    final int? overrideAmount = scenario.expenseAmountOverrides[expense.id];
    final int effectiveTotal = isActual
        ? (expense.actualPrice ?? 0)
        : (overrideAmount ?? expense.estimatedTotal);

    switch (expense.calcMode) {
      case ExpenseCalcMode.fixedEqual:
        return _calcFixedEqual(
          trip: trip,
          scenario: scenario,
          expense: expense,
          totalAmount: effectiveTotal,
        );

      case ExpenseCalcMode.fixedStageRatio:
        return _calcFixedStageRatio(
          trip: trip,
          scenario: scenario,
          expense: expense,
          totalAmount: effectiveTotal,
        );

      case ExpenseCalcMode.perPersonUnitPrice:
        return _calcPerPersonUnitPrice(
          trip: trip,
          scenario: scenario,
          expense: expense,
          isActual: isActual,
        );

      case ExpenseCalcMode.itemized:
        return _calcItemized(
          trip: trip,
          scenario: scenario,
          expense: expense,
          isActual: isActual,
        );
    }
  }

  Map<String, MemberExpenseBreakdown> _calcFixedEqual({
    required Trip trip,
    required Scenario scenario,
    required Expense expense,
    required int totalAmount,
  }) {
    // Effective bearers
    final bearerIds = <String>[];
    for (final m in trip.members) {
      if (expense.isCommitted) {
        final status = scenario.getEffectiveBearerStatus(expense, m.id);
        if (status != CostBearerStatus.manualExclude) {
          bearerIds.add(m.id);
        }
      } else {
        if (scenario.isMemberCostBearer(expense, m.id)) {
          bearerIds.add(m.id);
        }
      }
    }

    final result = <String, MemberExpenseBreakdown>{};
    if (bearerIds.isEmpty || totalAmount <= 0) {
      for (final m in trip.members) {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: 0,
          finalShare: 0,
          explanationNotes: bearerIds.isEmpty
              ? 'Khoản chi không có thành viên nào chịu tiền'
              : 'Chi phí bằng 0đ',
        );
      }
      return result;
    }

    final baseShare = totalAmount ~/ bearerIds.length;
    var remainder = totalAmount % bearerIds.length;

    for (final m in trip.members) {
      if (bearerIds.contains(m.id)) {
        int share = baseShare;
        if (remainder > 0) {
          share += 1;
          remainder--;
        }
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: share,
          finalShare: share,
          explanationNotes:
              'Cố định chia đều cho ${bearerIds.length} người: ${CurrencyFormatter.formatVnd(share)}',
        );
      } else {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: 0,
          finalShare: 0,
          explanationNotes: 'Không tham gia chịu khoản chi này',
        );
      }
    }
    return result;
  }

  Map<String, MemberExpenseBreakdown> _calcFixedStageRatio({
    required Trip trip,
    required Scenario scenario,
    required Expense expense,
    required int totalAmount,
  }) {
    final stagesToCheck =
        expense.stageIds.isNotEmpty ? expense.stageIds : [expense.stageId];

    final memberUnits = <String, int>{};
    int totalUnits = 0;

    for (final m in trip.members) {
      int count = 0;
      for (final sId in stagesToCheck) {
        if (scenario.isMemberPresentInStage(sId, m.id)) {
          count++;
        }
      }
      // Check manual overrides if any
      final status = scenario.getEffectiveBearerStatus(expense, m.id);
      if (status == CostBearerStatus.manualInclude && count == 0) {
        count = 1;
      } else if (status == CostBearerStatus.manualExclude) {
        count = 0;
      }

      memberUnits[m.id] = count;
      totalUnits += count;
    }

    final result = <String, MemberExpenseBreakdown>{};
    if (totalUnits == 0 || totalAmount <= 0) {
      for (final m in trip.members) {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: 0,
          finalShare: 0,
          explanationNotes: 'Không có chặng tính phí được tham gia',
        );
      }
      return result;
    }

    // Largest Remainder Allocation with BigInt
    final baseShares = <String, int>{};
    final fractions = <String, BigInt>{};
    int sumBase = 0;

    for (final m in trip.members) {
      final u = memberUnits[m.id]!;
      if (u > 0) {
        final numer = BigInt.from(totalAmount) * BigInt.from(u);
        final denom = BigInt.from(totalUnits);
        final share = (numer ~/ denom).toInt();
        final rem = numer % denom;
        baseShares[m.id] = share;
        fractions[m.id] = rem;
        sumBase += share;
      } else {
        baseShares[m.id] = 0;
        fractions[m.id] = BigInt.zero;
      }
    }

    int remainingToDistribute = totalAmount - sumBase;

    // Sort by largest remainder descending; break ties by member order
    final sortedMembers = List<String>.from(trip.members.map((m) => m.id));
    sortedMembers.sort((a, b) {
      final cmp = fractions[b]!.compareTo(fractions[a]!);
      return cmp;
    });

    for (final mId in sortedMembers) {
      if (remainingToDistribute > 0 && memberUnits[mId]! > 0) {
        baseShares[mId] = baseShares[mId]! + 1;
        remainingToDistribute--;
      }
    }

    for (final m in trip.members) {
      final share = baseShares[m.id] ?? 0;
      final u = memberUnits[m.id] ?? 0;
      result[m.id] = MemberExpenseBreakdown(
        memberId: m.id,
        expenseId: expense.id,
        expenseTitle: expense.title,
        baseAmount: share,
        finalShare: share,
        explanationNotes: u > 0
            ? 'Tham gia $u/$totalUnits chặng tính phí ($u chặng): ${CurrencyFormatter.formatVnd(share)}'
            : 'Không tham gia chặng nào trong khoản chi này',
      );
    }
    return result;
  }

  Map<String, MemberExpenseBreakdown> _calcPerPersonUnitPrice({
    required Trip trip,
    required Scenario scenario,
    required Expense expense,
    required bool isActual,
  }) {
    final bearerIds = <String>[];
    for (final m in trip.members) {
      if (expense.isCommitted) {
        final status = scenario.getEffectiveBearerStatus(expense, m.id);
        if (status != CostBearerStatus.manualExclude) {
          bearerIds.add(m.id);
        }
      } else {
        if (scenario.isMemberCostBearer(expense, m.id)) {
          bearerIds.add(m.id);
        }
      }
    }

    final int unitPrice;
    if (isActual && expense.actualPrice != null) {
      unitPrice = bearerIds.isNotEmpty
          ? expense.actualPrice! ~/ bearerIds.length
          : 0;
    } else {
      unitPrice = expense.unitPrice;
    }

    final result = <String, MemberExpenseBreakdown>{};
    for (final m in trip.members) {
      if (bearerIds.contains(m.id)) {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: unitPrice,
          finalShare: unitPrice,
          explanationNotes:
              'Đơn giá theo đầu người: ${CurrencyFormatter.formatVnd(unitPrice)}',
        );
      } else {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: 0,
          finalShare: 0,
          explanationNotes: 'Vắng mặt hoặc không chịu khoản chi này',
        );
      }
    }
    return result;
  }

  Map<String, MemberExpenseBreakdown> _calcItemized({
    required Trip trip,
    required Scenario scenario,
    required Expense expense,
    required bool isActual,
  }) {
    // Determine active buyers: members who have items AND are effective cost bearers
    final memberSubtotals = <String, int>{for (final m in trip.members) m.id: 0};
    final activeBuyerIds = <String>[];

    for (final item in expense.lineItems) {
      final isBearer = scenario.isMemberCostBearer(expense, item.bearerMemberId);
      if (isBearer) {
        memberSubtotals[item.bearerMemberId] =
            (memberSubtotals[item.bearerMemberId] ?? 0) + item.subtotal;
        if (!activeBuyerIds.contains(item.bearerMemberId)) {
          activeBuyerIds.add(item.bearerMemberId);
        }
      }
    }

    final totalItemsCost = activeBuyerIds.fold<int>(
      0,
      (sum, bId) => sum + (memberSubtotals[bId] ?? 0),
    );

    // Shipping Fee Allocation
    final shippingShares = <String, int>{for (final m in trip.members) m.id: 0};
    if (activeBuyerIds.isNotEmpty && expense.shippingFee > 0) {
      if (expense.shippingRule == ModifierAllocationRule.equalSplit) {
        final baseShip = expense.shippingFee ~/ activeBuyerIds.length;
        var rem = expense.shippingFee % activeBuyerIds.length;
        for (final m in trip.members) {
          if (activeBuyerIds.contains(m.id)) {
            int s = baseShip;
            if (rem > 0) {
              s += 1;
              rem--;
            }
            shippingShares[m.id] = s;
          }
        }
      } else {
        // Proportional to subtotal using Largest Remainder
        _allocateProportional(
          trip: trip,
          activeBuyerIds: activeBuyerIds,
          memberSubtotals: memberSubtotals,
          totalAmount: expense.shippingFee,
          totalSubtotal: totalItemsCost,
          outputMap: shippingShares,
        );
      }
    }

    // Discount Fee Allocation
    final discountShares = <String, int>{for (final m in trip.members) m.id: 0};
    if (activeBuyerIds.isNotEmpty && expense.discountFee > 0) {
      if (expense.discountRule == ModifierAllocationRule.proportionalToSubtotal) {
        _allocateProportional(
          trip: trip,
          activeBuyerIds: activeBuyerIds,
          memberSubtotals: memberSubtotals,
          totalAmount: expense.discountFee,
          totalSubtotal: totalItemsCost,
          outputMap: discountShares,
        );
      } else {
        final baseDisc = expense.discountFee ~/ activeBuyerIds.length;
        var rem = expense.discountFee % activeBuyerIds.length;
        for (final m in trip.members) {
          if (activeBuyerIds.contains(m.id)) {
            int d = baseDisc;
            if (rem > 0) {
              d += 1;
              rem--;
            }
            discountShares[m.id] = d;
          }
        }
      }
    }

    final result = <String, MemberExpenseBreakdown>{};
    for (final m in trip.members) {
      if (activeBuyerIds.contains(m.id)) {
        final itemCost = memberSubtotals[m.id] ?? 0;
        final ship = shippingShares[m.id] ?? 0;
        final disc = discountShares[m.id] ?? 0;
        final finalShare = itemCost + ship - disc;

        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: itemCost,
          shippingShare: ship,
          discountShare: disc,
          finalShare: finalShare,
          explanationNotes:
              'Món riêng: ${CurrencyFormatter.formatVnd(itemCost)} + Ship: ${CurrencyFormatter.formatVnd(ship)} - Giảm giá: ${CurrencyFormatter.formatVnd(disc)} = ${CurrencyFormatter.formatVnd(finalShare)}',
        );
      } else {
        result[m.id] = MemberExpenseBreakdown(
          memberId: m.id,
          expenseId: expense.id,
          expenseTitle: expense.title,
          baseAmount: 0,
          shippingShare: 0,
          discountShare: 0,
          finalShare: 0,
          explanationNotes: 'Không tham gia đặt món ở khoản chi này',
        );
      }
    }

    return result;
  }

  void _allocateProportional({
    required Trip trip,
    required List<String> activeBuyerIds,
    required Map<String, int> memberSubtotals,
    required int totalAmount,
    required int totalSubtotal,
    required Map<String, int> outputMap,
  }) {
    if (totalSubtotal <= 0 || totalAmount <= 0) return;

    final baseShares = <String, int>{};
    final fractions = <String, BigInt>{};
    int distributed = 0;

    for (final bId in activeBuyerIds) {
      final sub = memberSubtotals[bId]!;
      final numer = BigInt.from(totalAmount) * BigInt.from(sub);
      final denom = BigInt.from(totalSubtotal);
      final share = (numer ~/ denom).toInt();
      final rem = numer % denom;
      baseShares[bId] = share;
      fractions[bId] = rem;
      distributed += share;
    }

    int remainder = totalAmount - distributed;

    // Stable sort by fraction descending, preserving member order on ties
    final sortedBuyers = List<String>.from(activeBuyerIds);
    sortedBuyers.sort((a, b) {
      final cmp = fractions[b]!.compareTo(fractions[a]!);
      if (cmp != 0) return cmp;
      final idxA = trip.members.indexWhere((m) => m.id == a);
      final idxB = trip.members.indexWhere((m) => m.id == b);
      return idxA.compareTo(idxB);
    });

    for (final bId in sortedBuyers) {
      if (remainder > 0) {
        baseShares[bId] = (baseShares[bId] ?? 0) + 1;
        remainder--;
      }
    }

    for (final bId in activeBuyerIds) {
      outputMap[bId] = baseShares[bId] ?? 0;
    }
  }

  @override
  ScenarioComparison compareScenarios({
    required Trip trip,
    required Scenario baseline,
    required Scenario target,
  }) {
    final resBaseline = calculateScenario(trip: trip, scenario: baseline);
    final resTarget = calculateScenario(trip: trip, scenario: target);

    final tripDiff = resTarget.totalTripCost - resBaseline.totalTripCost;

    final memberDiffs = <String, int>{};
    for (final m in trip.members) {
      final cTarget = resTarget.getMemberCost(m.id);
      final cBaseline = resBaseline.getMemberCost(m.id);
      memberDiffs[m.id] = cTarget - cBaseline;
    }

    final stageDiffs = <String, int>{};
    for (final s in trip.stages) {
      final sTarget = resTarget.stageSummaries[s.id] ?? 0;
      final sBaseline = resBaseline.stageSummaries[s.id] ?? 0;
      stageDiffs[s.id] = sTarget - sBaseline;
    }

    return ScenarioComparison(
      baselineScenarioId: baseline.id,
      targetScenarioId: target.id,
      tripDifference: tripDiff,
      memberDifferences: memberDiffs,
      stageDifferences: stageDiffs,
    );
  }

  @override
  SettlementValidation validateSettlement({
    required Trip trip,
    required Scenario scenario,
  }) {
    final reasons = <String>[];

    // 1. Any expense with amount > 0 but 0 bearers?
    for (final exp in trip.expenses) {
      final hasBearer = trip.members.any((m) =>
          scenario.isMemberCostBearer(exp, m.id) ||
          (exp.isCommitted &&
              scenario.getEffectiveBearerStatus(exp, m.id) !=
                  CostBearerStatus.manualExclude));

      final amount = exp.actualPrice ?? exp.estimatedTotal;
      if (amount > 0 && !hasBearer) {
        reasons.add(
          'Khoản chi "${exp.title}" có số tiền ${CurrencyFormatter.formatVnd(amount)} nhưng chưa có ai chịu tiền.',
        );
      }
    }

    // 2. If in Actual mode, check for unentered actualPrice
    if (trip.isLedgerInitialized) {
      for (final exp in trip.expenses) {
        if (exp.actualPrice == null) {
          reasons.add(
            'Khoản chi "${exp.title}" chưa được nhập giá thực tế (hoặc chưa đánh dấu không phát sinh).',
          );
        }
      }
    }

    // 3. Precondition: Check payment coverage
    // If expenses have been incurred, ensure cash transactions exist to pay for them
    final totalExpenseAmount = trip.expenses.fold<int>(
      0,
      (sum, e) => sum + (e.actualPrice ?? e.estimatedTotal),
    );

    int totalSupplierPayments = 0;
    int totalOutOfPocketPayments = 0;
    for (final tx in trip.cashTransactions) {
      if (tx.type == CashTransactionType.supplierPayment) {
        totalSupplierPayments += tx.amount;
      } else if (tx.type == CashTransactionType.outOfPocketPayment) {
        totalOutOfPocketPayments += tx.amount;
      }
    }

    if (totalExpenseAmount > 0 &&
        totalSupplierPayments == 0 &&
        totalOutOfPocketPayments == 0) {
      reasons.add(
        'Chưa có giao dịch thanh toán hóa đơn nào được ghi nhận cho các chi phí phát sinh (${CurrencyFormatter.formatVnd(totalExpenseAmount)}).',
      );
    }

    return SettlementValidation(
      canSettle: reasons.isEmpty,
      blockingReasons: reasons,
    );
  }

  @override
  SettlementResult calculateSettlement({
    required Trip trip,
    required Scenario scenario,
    required SettlementMethod method,
  }) {
    final validation = validateSettlement(trip: trip, scenario: scenario);

    // Compute cost obligations
    final scenarioResult = trip.isLedgerInitialized
        ? calculateActual(trip: trip, scenario: scenario)
        : calculateScenario(trip: trip, scenario: scenario);

    final fundContributed = <String, int>{for (final m in trip.members) m.id: 0};
    final outOfPocket = <String, int>{for (final m in trip.members) m.id: 0};
    final refunded = <String, int>{for (final m in trip.members) m.id: 0};
    final memberTransfersPaid = <String, int>{for (final m in trip.members) m.id: 0};
    final memberTransfersReceived = <String, int>{for (final m in trip.members) m.id: 0};

    for (final tx in trip.cashTransactions) {
      if (tx.type == CashTransactionType.fundContribution) {
        fundContributed[tx.payerMemberId] =
            (fundContributed[tx.payerMemberId] ?? 0) + tx.amount;
      } else if (tx.type == CashTransactionType.outOfPocketPayment) {
        outOfPocket[tx.payerMemberId] =
            (outOfPocket[tx.payerMemberId] ?? 0) + tx.amount;
      } else if (tx.type == CashTransactionType.refund) {
        refunded[tx.recipient] = (refunded[tx.recipient] ?? 0) + tx.amount;
      } else if (tx.type == CashTransactionType.memberTransfer) {
        memberTransfersPaid[tx.payerMemberId] =
            (memberTransfersPaid[tx.payerMemberId] ?? 0) + tx.amount;
        memberTransfersReceived[tx.recipient] =
            (memberTransfersReceived[tx.recipient] ?? 0) + tx.amount;
      }
    }

    final debtSummaries = <MemberDebtSummary>[];
    for (final member in trip.members) {
      final cost = scenarioResult.getMemberCost(member.id);
      final fund = fundContributed[member.id] ?? 0;
      final oop = outOfPocket[member.id] ?? 0;
      final ref = refunded[member.id] ?? 0;
      final xferPaid = memberTransfersPaid[member.id] ?? 0;
      final xferRecv = memberTransfersReceived[member.id] ?? 0;

      debtSummaries.add(MemberDebtSummary(
        memberId: member.id,
        memberName: member.name,
        costObligation: cost,
        fundContributed: fund + xferPaid,
        outOfPocketPaid: oop,
        refunded: ref + xferRecv,
      ));
    }

    final fundCashOnHand = trip.fundCashBalance;

    // Generate Transfer Steps
    final transferSteps = <SettlementTransferStep>[];
    final treasurer = trip.treasurer ?? (trip.members.isNotEmpty ? trip.members.first : null);
    final treasurerName = treasurer?.name ?? 'Thủ quỹ';
    final treasurerId = treasurer?.id ?? 'fund';

    if (method == SettlementMethod.viaFund) {
      // Step 1: Debtors pay into Fund
      for (final ds in debtSummaries) {
        if (ds.needsToPay && ds.amountToPay > 0) {
          // If debtor is treasurer, no self-transfer step needed
          if (ds.memberId != treasurerId) {
            transferSteps.add(
              SettlementTransferStep(
                id: 'step_pay_${ds.memberId}',
                fromMemberId: ds.memberId,
                fromMemberName: ds.memberName,
                toMemberId: treasurerId,
                toMemberName: treasurerName,
                amount: ds.amountToPay,
                isViaFund: true,
              ),
            );
          }
        }
      }

      // Step 2: Fund refunds creditors
      for (final ds in debtSummaries) {
        if (ds.getsRefund && ds.amountToReceive > 0) {
          if (ds.memberId != treasurerId) {
            transferSteps.add(
              SettlementTransferStep(
                id: 'step_refund_${ds.memberId}',
                fromMemberId: treasurerId,
                fromMemberName: treasurerName,
                toMemberId: ds.memberId,
                toMemberName: ds.memberName,
                amount: ds.amountToReceive,
                isViaFund: true,
              ),
            );
          }
        }
      }
    } else {
      // Direct Transfer (Chuyển khoản chéo trực tiếp)
      // First, handle surplus cash in fund if any
      int remainingFundCash = fundCashOnHand;
      final mutableCreditors = <String, int>{};
      final mutableDebtors = <String, int>{};

      for (final ds in debtSummaries) {
        if (ds.getsRefund && ds.amountToReceive > 0) {
          mutableCreditors[ds.memberId] = ds.amountToReceive;
        } else if (ds.needsToPay && ds.amountToPay > 0) {
          mutableDebtors[ds.memberId] = ds.amountToPay;
        }
      }

      // If there is fund cash on hand, pay back creditors from fund cash first
      if (remainingFundCash > 0) {
        for (final creditorEntry in List.of(mutableCreditors.entries)) {
          if (remainingFundCash <= 0) break;
          final cId = creditorEntry.key;
          final cAmount = creditorEntry.value;
          final payFromFund = remainingFundCash >= cAmount ? cAmount : remainingFundCash;

          if (payFromFund > 0) {
            final cMember = trip.getMember(cId);
            if (cId != treasurerId) {
              transferSteps.add(
                SettlementTransferStep(
                  id: 'step_direct_fund_$cId',
                  fromMemberId: treasurerId,
                  fromMemberName: treasurerName,
                  toMemberId: cId,
                  toMemberName: cMember?.name ?? cId,
                  amount: payFromFund,
                  isViaFund: true,
                ),
              );
            }
            remainingFundCash -= payFromFund;
            final remainingCredit = cAmount - payFromFund;
            if (remainingCredit <= 0) {
              mutableCreditors.remove(cId);
            } else {
              mutableCreditors[cId] = remainingCredit;
            }
          }
        }
      }

      // Greedy bipartite matching between remaining debtors and creditors
      int stepCounter = 1;
      while (mutableDebtors.isNotEmpty && mutableCreditors.isNotEmpty) {
        // Find largest debtor
        final debtorEntry = mutableDebtors.entries
            .reduce((a, b) => a.value >= b.value ? a : b);
        // Find largest creditor
        final creditorEntry = mutableCreditors.entries
            .reduce((a, b) => a.value >= b.value ? a : b);

        final debtorId = debtorEntry.key;
        final creditorId = creditorEntry.key;
        final debtAmount = debtorEntry.value;
        final creditAmount = creditorEntry.value;

        if (debtorId == creditorId) {
          // Cannot transfer to self
          mutableDebtors.remove(debtorId);
          continue;
        }

        final transferAmount =
            debtAmount <= creditAmount ? debtAmount : creditAmount;

        final debtorMember = trip.getMember(debtorId);
        final creditorMember = trip.getMember(creditorId);

        transferSteps.add(
          SettlementTransferStep(
            id: 'step_direct_${stepCounter++}_${debtorId}_$creditorId',
            fromMemberId: debtorId,
            fromMemberName: debtorMember?.name ?? debtorId,
            toMemberId: creditorId,
            toMemberName: creditorMember?.name ?? creditorId,
            amount: transferAmount,
            isViaFund: false,
          ),
        );

        if (debtAmount <= creditAmount) {
          mutableDebtors.remove(debtorId);
        } else {
          mutableDebtors[debtorId] = debtAmount - transferAmount;
        }

        if (creditAmount <= debtAmount) {
          mutableCreditors.remove(creditorId);
        } else {
          mutableCreditors[creditorId] = creditAmount - transferAmount;
        }
      }
    }

    return SettlementResult(
      validation: validation,
      method: method,
      debtSummaries: debtSummaries,
      transferSteps: transferSteps,
      fundCashOnHand: fundCashOnHand,
    );
  }
}
