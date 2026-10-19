import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_travel_caculate/domain/models/expense.dart';
import 'package:group_travel_caculate/presentation/widgets/cost_bearer_checkbox.dart';

void main() {
  testWidgets('CostBearerCheckbox hiển thị đúng 3 trạng thái và chuyển trạng thái', (tester) async {
    CostBearerStatus currentStatus = CostBearerStatus.inherited;
    bool resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return CostBearerCheckbox(
                memberName: 'Nguyễn Văn An',
                isPresentInStage: true,
                status: currentStatus,
                onChanged: (newStatus) {
                  setState(() => currentStatus = newStatus);
                },
                onResetToInherited: () {
                  resetCalled = true;
                  setState(() => currentStatus = CostBearerStatus.inherited);
                },
              );
            },
          ),
        ),
      ),
    );

    // Trạng thái 1: Kế thừa (Tự động có mặt)
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('Tự động (Có mặt)'), findsOneWidget);
    expect(find.byIcon(Icons.restore), findsNothing);

    // Tap chuyển sang trạng thái 2: Bỏ thủ công (Manual Exclude)
    await tester.tap(find.text('Nguyễn Văn An'));
    await tester.pumpAndSettle();

    expect(currentStatus, CostBearerStatus.manualExclude);
    expect(find.text('Miễn trừ (Thủ công)'), findsOneWidget);
    expect(find.byIcon(Icons.restore), findsOneWidget);

    // Tap nút Reset to inherited
    await tester.tap(find.byIcon(Icons.restore));
    await tester.pumpAndSettle();

    expect(resetCalled, true);
    expect(currentStatus, CostBearerStatus.inherited);
    expect(find.text('Tự động (Có mặt)'), findsOneWidget);
  });
}
