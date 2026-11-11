import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airscope/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AirScope displays city search interface', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AirScopeApp());

    expect(find.text('AirScope'), findsOneWidget);
    expect(find.text('Pantau kualitas udara'), findsOneWidget);

    expect(find.byType(TextField), findsOneWidget);

    expect(find.text('Mulai pencarian lokasi'), findsOneWidget);
  });

  testWidgets('City search field accepts user input', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AirScopeApp());

    await tester.enterText(find.byType(TextField), 'Makassar');

    expect(find.text('Makassar'), findsOneWidget);
  });
}
