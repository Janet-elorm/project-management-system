import 'package:capstone_flutter/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // Correct import

void main() {
  testWidgets('Login button appears', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage())); // pump LoginPage only

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Empty email shows validation error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    final loginButton = find.text('Sign in');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('Empty password shows validation error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'test@example.com');

    final loginButton = find.text('Sign in');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text('Password is required'), findsOneWidget);
  });
}
