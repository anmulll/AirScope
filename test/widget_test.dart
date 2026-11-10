import 'package:flutter_test/flutter_test.dart';
import 'package:airscope/app/app.dart';

void main() {
  testWidgets('AirScope displays initial home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AirScopeApp());

    expect(find.text('AirScope'), findsOneWidget);
    expect(find.text('Pantau kualitas udara'), findsOneWidget);
    expect(find.textContaining('US AQI'), findsOneWidget);
  });
}
