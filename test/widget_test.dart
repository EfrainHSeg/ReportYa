import 'package:flutter_test/flutter_test.dart';
import 'package:reportya/app/app.dart';

void main() {
  testWidgets('ReportYaApp renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ReportYaApp());

    expect(find.text('Nuevo reporte'), findsNothing);
    expect(find.byType(ReportYaApp), findsOneWidget);
  });
}
