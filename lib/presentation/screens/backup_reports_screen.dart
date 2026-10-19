import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/services/report_export_service.dart';
import '../../viewmodels/backup_report_viewmodel.dart';

class BackupReportsScreen extends StatefulWidget {
  final String tripId;

  const BackupReportsScreen({super.key, required this.tripId});

  @override
  State<BackupReportsScreen> createState() => _BackupReportsScreenState();
}

class _BackupReportsScreenState extends State<BackupReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedExcelSheetIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupReportViewModel>().loadTrip(widget.tripId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showImportPasteDialog() {
    final ctrl = TextEditingController();
    final vm = context.read<BackupReportViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập file sao lưu (.grouptrip.json)'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dán nội dung JSON từ file sao lưu của bạn vào khung bên dưới để xem trước và nhập dữ liệu:',
                style: TextStyle(fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: '{\n  "schemaVersion": "1.0.0",\n  "trip": { ... }\n}',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                vm.previewImport(text);
                Navigator.of(ctx).pop();
                _showImportPreviewDialog();
              }
            },
            child: const Text('Kiểm tra & Xem trước'),
          ),
        ],
      ),
    );
  }

  void _showImportPreviewDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer<BackupReportViewModel>(
          builder: (context, vm, _) {
            if (vm.isImporting) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang xác thực và giải mã file sao lưu...'),
                  ],
                ),
              );
            }

            if (vm.importError != null) {
              return AlertDialog(
                title: const Text('File không hợp lệ', style: TextStyle(color: AppColors.error)),
                content: Text(vm.importError!),
                actions: [
                  TextButton(
                    onPressed: () {
                      vm.cancelImportPreview();
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            }

            final trip = vm.previewedTrip;
            if (trip == null) {
              return const SizedBox.shrink();
            }

            return AlertDialog(
              title: const Text('Xác nhận nhập chuyến đi (Xem trước)'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thủ quỹ: ${trip.treasurer?.name ?? "Chưa rõ"} • ${trip.members.length} thành viên • ${trip.stages.length} chặng • ${trip.expenses.length} khoản chi',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Lưu ý an toàn: Dữ liệu này sẽ được nhập thành một BẢN SAO ĐỘC LẬP trong danh sách chuyến đi của bạn để không ghi đè hay làm mất dữ liệu hiện có.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    vm.cancelImportPreview();
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Hủy bỏ'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final imported = await vm.commitImport(vm.exportedJson ?? '');
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (imported != null && mounted) {
                      context.go('/trips/${imported.id}/overview');
                    }
                  },
                  child: const Text('Nhập thành bản sao'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/trips/${widget.tripId}/overview');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BackupReportViewModel>();
    final trip = vm.trip;

    if (vm.isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
            onPressed: () => _handleBack(context),
          ),
          title: const Text('Xem Trước Báo Cáo & Sao Lưu Dữ Liệu'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
            onPressed: () => _handleBack(context),
          ),
          title: const Text('Xem Trước Báo Cáo & Sao Lưu Dữ Liệu'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.errorMessage ?? 'Không tìm thấy chuyến đi',
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Về màn hình Tổng quan'),
                onPressed: () => _handleBack(context),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
          onPressed: () => _handleBack(context),
        ),
        title: const Text('Xem Trước Báo Cáo & Sao Lưu Dữ Liệu'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.table_view_outlined), text: 'Xem trước Excel (7 Tab)'),
            Tab(icon: Icon(Icons.picture_as_pdf_outlined), text: 'Xem trước PDF'),
            Tab(icon: Icon(Icons.backup_outlined), text: 'Sao lưu .grouptrip.json'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Honest Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.warningContainer.withOpacity(0.7),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.onWarningContainer),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'LƯU Ý TRUNG THỰC: Đây là Bản xem trước (Preview) cấu trúc dữ liệu trên giao diện. Việc ghi file vật lý (.xlsx / .pdf) và mở hộp thoại lưu tệp thuộc giai đoạn Backend Local tiếp theo.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onWarningContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildExcelPreviewTab(vm),
                _buildPdfPreviewTab(vm),
                _buildBackupJsonTab(vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcelPreviewTab(BackupReportViewModel vm) {
    final excel = vm.excelPreview;
    if (excel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentSheet = excel.sheets[_selectedExcelSheetIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'File xem trước: ${excel.fileName}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '7 Sheets đầy đủ',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSuccessContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sheets Navigation Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(excel.sheets.length, (index) {
                final sheet = excel.sheets[index];
                final isSelected = index == _selectedExcelSheetIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sheet.title),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedExcelSheetIndex = index);
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Current Sheet Data Table
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                    columns: currentSheet.headers
                        .map((h) => DataColumn(
                              label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                    rows: currentSheet.rows
                        .map((row) => DataRow(
                              cells: row.map((cell) => DataCell(Text(cell))).toList(),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreviewTab(BackupReportViewModel vm) {
    final pdf = vm.pdfPreview;
    if (pdf == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pdf.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pdf.subtitle,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pdf.generatedAt,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: pdf.status == ReportDocumentStatus.settled
                              ? AppColors.successContainer
                              : (pdf.status == ReportDocumentStatus.provisional
                                  ? AppColors.warningContainer
                                  : AppColors.primaryContainer),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: pdf.status == ReportDocumentStatus.settled
                                ? AppColors.success
                                : (pdf.status == ReportDocumentStatus.provisional
                                    ? AppColors.warning
                                    : AppColors.primary),
                          ),
                        ),
                        child: Text(
                          'Trạng thái: ${pdf.status.displayName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pdf.status == ReportDocumentStatus.settled
                                ? AppColors.onSuccessContainer
                                : (pdf.status == ReportDocumentStatus.provisional
                                    ? AppColors.onWarningContainer
                                    : AppColors.onPrimaryContainer),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Summary Cards
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: pdf.summaryCards.map((card) {
                      return Container(
                        width: 170,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['title']!,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card['value']!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Member details
                  const Text(
                    'Chi Tiết Nghĩa Vụ Chi Trả Từng Thành Viên',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(color: AppColors.outlineVariant),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: AppColors.surfaceVariant),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Thành viên',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Phải chịu',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Đã góp quỹ',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Đã ứng trước',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Kết quả',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                      ...pdf.memberDetails.map((m) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${m['name']} ${m['isTreasurer'] == true ? "(Thủ quỹ)" : ""}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${m['cost']}', style: const TextStyle(fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${m['fund']}', style: const TextStyle(fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text('${m['outOfPocket']}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                '${m['netStatus']}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Settlement Instructions
                  const Text(
                    'Hướng Dẫn Quyết Toán & Chuyển Tiền',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...pdf.settlementInstructions.map(
                    (inst) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right, size: 18, color: AppColors.primary),
                          Expanded(
                            child: Text(
                              inst,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackupJsonTab(BackupReportViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sao lưu & Nhập file (.grouptrip.json)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Định dạng JSON chuẩn chứa dữ liệu nền, kịch bản, sổ thực tế và giao dịch',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showImportPasteDialog,
                    icon: const Icon(Icons.file_upload, size: 18),
                    label: const Text('Nhập file sao lưu'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => vm.exportSingleTrip(),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Sinh file JSON chuyến hiện tại'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => vm.exportAllTrips(),
                    icon: const Icon(Icons.folder_zip_outlined, size: 18),
                    label: const Text('Sinh file JSON toàn bộ chuyến đi'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (vm.isExporting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (vm.exportedJson != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Xem trước nội dung file JSON:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: vm.exportedJson!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã sao chép nội dung JSON vào bộ nhớ đệm')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Sao chép JSON'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 320,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      vm.exportedJson!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
