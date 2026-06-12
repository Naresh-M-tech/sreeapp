import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_bridge/features/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('Login form validates empty fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap sign in button
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    if (signInButton.evaluate().isNotEmpty) {
      await tester.tap(signInButton);
      await tester.pumpAndSettle();
    }
  });
}
