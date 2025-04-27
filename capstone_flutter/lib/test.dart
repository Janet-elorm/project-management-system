import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_flutter/main.dart'; // or wherever your app starts

void main() {
  testWidgets('Login button appears', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login'), findsOneWidget);
  });
}
