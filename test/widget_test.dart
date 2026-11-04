// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frizalia/Screens/perfil_screen.dart';
import 'package:frizalia/main.dart';

void main() {
  testWidgets('Splash screen navigates to profile after 3 seconds', (WidgetTester tester) async {
    await tester.pumpWidget(const FrizaliaApp());

    expect(find.text('Delfines Store'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
