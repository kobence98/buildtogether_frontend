// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_frontend/auth/login_widget.dart';
import 'package:flutter_frontend/auth/registration_widget.dart';
import 'package:flutter_frontend/languages/hungarian_language.dart';
import 'package:flutter_frontend/languages/languages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetForTesting({Widget? child}) {
    return MaterialApp(
      home: child,
    );
  }

  // LOGIN PAGE
  testWidgets('TEST1: Registration button opens registration page', (WidgetTester tester) async {
    Languages language = LanguageHu();

    await tester.pumpWidget(
      createWidgetForTesting(
        child: LoginPage(
          languages: language,
        ),
      ),
    );

    final regButton = find.byKey(new Key('registrationButton'));

    await tester.tap(regButton);
    await tester.pumpAndSettle();

    expect(find.byType(RegistrationWidget), findsOneWidget);
  });
}
