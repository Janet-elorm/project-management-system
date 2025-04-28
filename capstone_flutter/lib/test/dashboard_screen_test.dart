import 'package:capstone_flutter/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // Adjust the path if needed

void main() {
  testWidgets('Dashboard screen shows title and project list', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DashboardPage()));

    // Check if the screen title exists
    expect(find.text('My Projects'), findsOneWidget);

    // Check if there are project cards or loading indicator
    expect(find.byType(Card), findsWidgets); // Assumes you use Card widgets for projects
  });
}
