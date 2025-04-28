import 'package:capstone_flutter/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart'; // adjust path if needed

void main() {
  testWidgets('Login button appears', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Empty email shows validation error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Tap the login button without entering email or password
    final loginButton = find.text('Sign in');
    await tester.tap(loginButton);
    await tester.pump(); // Trigger form validation

    // Should show error "Email is required"
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('Empty password shows validation error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    // Enter email but leave password empty
    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, 'test@example.com');

    final loginButton = find.text('Sign in');
    await tester.tap(loginButton);
    await tester.pump(); // Trigger form validation

    // Should show error "Password is required"
    expect(find.text('Password is required'), findsOneWidget);
  });
}
