import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/responsive_layout.dart';
import '../../domain/models/attendance.dart';
import '../../domain/models/scenario.dart';
import '../../domain/models/stage.dart';
import '../../viewmodels/scenarios_comparison_viewmodel.dart';
import '../widgets/drilldown_dialog.dart';
import '../widgets/stale_calculation_banner.dart';

class ScenariosScreen extends StatefulWidget {
  final String tripId;

  const ScenariosScreen({super.key, required this.tripId});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScenariosComparisonViewModel>().loadTrip(widget.tripId);
    });
  }

  void _showPresetDialog(String memberId, String memberName) {
    final vm = context.read<ScenariosComparisonViewModel>();
    final stages = vm.trip?.stages ?? [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chọn lịch trình cho $memberName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
              title: const Text('Đi đủ tất cả các chặng'),
              onTap: () {
                vm.applyAttendancePreset(
                  memberId: memberId,
                  presetType: AttendancePresetType.full,
                );
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.info),
              title: const Text('Đến từ chặng chỉ định...'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showStagePickDialog(memberId, AttendancePresetType.fromStage, stages);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.warning),
              title: const Text('Về sau chặng chỉ định...'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showStagePickDialog(memberId, AttendancePresetType.untilStage, stages);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.error),
              title: const Text('Nghỉ hoàn toàn chuyến đi'),
              onTap: () {
                vm.applyAttendancePreset(
                  memberId: memberId,
                  presetType: AttendancePresetType.absent,
                );
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStagePickDialog(
    String memberId,
    AttendancePresetType type,
    List<Stage> stages,
  ) {
    final vm = context.read<ScenariosComparisonViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == AttendancePresetType.fromStage
            ? 'Đến từ chặng nào?'
            : 'Về sau chặng nào?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: stages.map((s) {
            return ListTile(
              title: Text('${s.order}. ${s.name}'),
              onTap: () {
                vm.applyAttendancePreset(
                  memberId: memberId,
                  presetType: type,
                  targetStageId: s.id,
                );
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScenariosComparisonViewModel>();
    final trip = vm.trip;

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trip == null) {
      return Center(
        child: Text(
          vm.errorMessage ?? 'Không tìm thấy kịch bản',
          style: const TextStyle(color: AppColors.error),
        ),
      );
    }

    final selectedScenario = vm.selectedScenario;
    final calcResult = vm.calculationResult;
    final comparison = vm.comparison;
    final isCompact = ResponsiveLayout.isCompact(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scenario Selector & Management Bar
              Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Kịch bản:',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedScenario?.id,
                        underline: Container(height: 1.5, color: AppColors.primary),
                        onChanged: (scId) {
                          if (scId != null) vm.selectScenario(scId);
                        },
                        items: vm.scenarios.map((sc) {
                          return DropdownMenuItem(
                            value: sc.id,
                            child: Text(
                              sc.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      OutlinedButton.icon(
                        onPressed: selectedScenario != null
                            ? () => vm.duplicateScenario(selectedScenario.id)
                            : null,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Nhân bản kịch bản'),
                      ),
                      if (selectedScenario != null && !selectedScenario.isBaseline)
                        TextButton.icon(
                          onPressed: () => vm.setAsBaseline(selectedScenario.id),
                          icon: const Icon(Icons.bookmark_outline, size: 16),
                          label: const Text('Đặt làm mốc so sánh'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stale Banner if inputs were edited
              if (selectedScenario?.isStale == true || calcResult?.isStale == true)
                StaleCalculationBanner(
                  onResetToFixture: () => vm.resetToFixtureData(),
                ),

              // Scenario Total Metric
              if (calcResult != null && !calcResult.isStale) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng chi phí kịch bản "${selectedScenario?.name}":',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Bấm vào tên từng thành viên bên dưới để xem bóc tách chi tiết (Drill-down).',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatVnd(calcResult.totalTripCost),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Adaptive Attendance Matrix (Desktop/Tablet) vs List (Mobile)
              const Text(
                'Ma trận có mặt theo từng chặng (Attendance Matrix)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tích chọn để đánh dấu có mặt. Nhấn vào tên thành viên để chọn Preset lịch trình (Đi đủ, Nghỉ, Đến sau...).',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              if (isCompact)
                _buildMobileAttendanceList(trip, selectedScenario, vm)
              else
                _buildDesktopAttendanceMatrix(trip, selectedScenario, vm),

              const SizedBox(height: 32),

              // Scenario Comparison Table
              const Divider(height: 1),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Bảng So Sánh Kịch Bản (What-if Comparison)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mốc so sánh:', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: vm.baselineScenario?.id,
                        underline: Container(height: 1, color: AppColors.outline),
                        onChanged: (scId) {
                          if (scId != null) vm.selectBaseline(scId);
                        },
                        items: vm.scenarios.map((sc) {
                          return DropdownMenuItem(
                            value: sc.id,
                            child: Text(sc.name, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (calcResult != null && !calcResult.isStale && comparison != null)
                _buildComparisonTable(trip, vm, calcResult, comparison)
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Bảng so sánh tạm thời bị khóa do kịch bản có đầu vào bị thay đổi ngoài fixture.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopAttendanceMatrix(
    dynamic trip,
    Scenario? scenario,
    ScenariosComparisonViewModel vm,
  ) {
    if (scenario == null) return const SizedBox.shrink();

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
          columns: [
            const DataColumn(
              label: Text(
                'Thành viên',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const DataColumn(
              label: Text(
                'Preset lịch trình',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...trip.stages.map<DataColumn>((stage) {
              return DataColumn(
                label: Text(
                  '${stage.order}. ${stage.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              );
            }),
            const DataColumn(
              label: Text(
                'Nghĩa vụ chi phí',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          rows: trip.members.map<DataRow>((member) {
            final summary = vm.calculationResult?.memberSummaries[member.id];
            final memberCost = summary?.totalCost ?? 0;

            return DataRow(
              cells: [
                DataCell(
                  InkWell(
                    onTap: () {
                      if (summary != null) {
                        DrilldownDialog.show(context, member: member, summary: summary);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    onPressed: () => _showPresetDialog(member.id, member.name),
                    icon: const Icon(Icons.tune, size: 14),
                    label: const Text('Lịch trình', style: TextStyle(fontSize: 12)),
                  ),
                ),
                ...trip.stages.map<DataCell>((stage) {
                  final isPresent = scenario.isMemberPresentInStage(stage.id, member.id);
                  return DataCell(
                    Checkbox(
                      value: isPresent,
                      activeColor: AppColors.primary,
                      onChanged: (_) {
                        vm.toggleAttendance(stageId: stage.id, memberId: member.id);
                      },
                    ),
                  );
                }),
                DataCell(
                  Text(
                    CurrencyFormatter.formatVnd(memberCost),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileAttendanceList(
    dynamic trip,
    Scenario? scenario,
    ScenariosComparisonViewModel vm,
  ) {
    if (scenario == null) return const SizedBox.shrink();

    return Column(
      children: trip.members.map<Widget>((member) {
        final summary = vm.calculationResult?.memberSummaries[member.id];
        final memberCost = summary?.totalCost ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (summary != null) {
                          DrilldownDialog.show(context, member: member, summary: summary);
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatVnd(memberCost),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Các chặng tham gia:', style: TextStyle(fontSize: 12)),
                    TextButton.icon(
                      onPressed: () => _showPresetDialog(member.id, member.name),
                      icon: const Icon(Icons.tune, size: 14),
                      label: const Text('Preset', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: trip.stages.map<Widget>((stage) {
                    final isPresent = scenario.isMemberPresentInStage(stage.id, member.id);
                    return FilterChip(
                      label: Text('${stage.order}. ${stage.name}'),
                      selected: isPresent,
                      onSelected: (_) {
                        vm.toggleAttendance(stageId: stage.id, memberId: member.id);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonTable(
    dynamic trip,
    ScenariosComparisonViewModel vm,
    dynamic calcResult,
    dynamic comparison,
  ) {
    final baseRes = vm.baselineResult;
    final baseName = vm.baselineScenario?.name ?? 'Mốc';
    final targetName = vm.selectedScenario?.name ?? 'Hiện tại';

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
          columns: [
            const DataColumn(
              label: Text('Hạng mục so sánh', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Mốc: $baseName', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            DataColumn(
              label: Text('Đang xem: $targetName',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const DataColumn(
              label: Text('Chênh lệch (+/-)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
          rows: [
            // Tổng chuyến đi
            DataRow(
              color: WidgetStateProperty.all(AppColors.primaryContainer.withOpacity(0.3)),
              cells: [
                const DataCell(
                  Text('TỔNG TOÀN CHUYẾN',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                ),
                DataCell(
                  Text(
                    CurrencyFormatter.formatVnd(baseRes?.totalTripCost ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DataCell(
                  Text(
                    CurrencyFormatter.formatVnd(calcResult.totalTripCost),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DataCell(
                  _buildDiffBadge(comparison.tripDifference),
                ),
              ],
            ),
            // Từng thành viên
            ...trip.members.map<DataRow>((member) {
              final bCost = baseRes?.getMemberCost(member.id) ?? 0;
              final tCost = calcResult.getMemberCost(member.id);
              final diff = comparison.memberDifferences[member.id] ?? 0;

              return DataRow(
                cells: [
                  DataCell(
                    Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  DataCell(Text(CurrencyFormatter.formatVnd(bCost))),
                  DataCell(Text(CurrencyFormatter.formatVnd(tCost))),
                  DataCell(_buildDiffBadge(diff)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffBadge(int diff) {
    if (diff == 0) {
      return const Text('0 đ', style: TextStyle(color: AppColors.textMuted));
    }
    final isIncrease = diff > 0;
    final color = isIncrease ? AppColors.error : AppColors.success;
    final bgColor = isIncrease ? AppColors.errorContainer : AppColors.successContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        CurrencyFormatter.formatSignedVnd(diff),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
