import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ootday_owner/main.dart';

void main() {
  testWidgets('Ootday Owner app loads smoke test', (WidgetTester tester) async {
    final deps = AppDependencies.build();
    await tester.pumpWidget(MyApp(deps: deps));

    // Verify that MaterialApp is mounted and renders without exception.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Clean up polling timer to avoid pending timer exception.
    deps.notificationProvider.dispose();
  });
}
