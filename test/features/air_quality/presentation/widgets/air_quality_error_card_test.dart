import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/presentation/widgets/air_quality_error_card.dart';

void main() {
  testWidgets('Error card displays message and retry button', (
    WidgetTester tester,
  ) async {
    var retryCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AirQualityErrorCard(
            title: 'Koneksi terputus',
            message: 'Periksa koneksi internet dan coba kembali.',
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Koneksi terputus'), findsOneWidget);

    expect(find.text('Coba Lagi'), findsOneWidget);

    expect(retryCalled, isFalse);

    await tester.tap(find.text('Coba Lagi'));

    expect(retryCalled, isTrue);
  });
}
