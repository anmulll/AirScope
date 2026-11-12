import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/presentation/widgets/city_search_field.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createWidget({
    required VoidCallback onSearch,
    bool isLoading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CitySearchField(
          controller: controller,
          onSearch: onSearch,
          isLoading: isLoading,
        ),
      ),
    );
  }

  group('CitySearchField', () {
    testWidgets('displays search input and hint text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(onSearch: () {}));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Contoh: Makassar'), findsOneWidget);
      expect(find.byTooltip('Cari kota'), findsOneWidget);
    });

    testWidgets('accepts user input', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(onSearch: () {}));

      await tester.enterText(find.byType(TextField), 'Makassar');

      expect(controller.text, 'Makassar');
    });

    testWidgets('calls search callback when button is tapped', (
      WidgetTester tester,
    ) async {
      var searchCalled = false;

      await tester.pumpWidget(
        createWidget(
          onSearch: () {
            searchCalled = true;
          },
        ),
      );

      await tester.tap(find.byTooltip('Cari kota'));

      expect(searchCalled, isTrue);
    });

    testWidgets('calls search callback when keyboard search is submitted', (
      WidgetTester tester,
    ) async {
      var searchCalled = false;

      await tester.pumpWidget(
        createWidget(
          onSearch: () {
            searchCalled = true;
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(searchCalled, isTrue);
    });

    testWidgets('disables search button while loading', (
      WidgetTester tester,
    ) async {
      var searchCalled = false;

      await tester.pumpWidget(
        createWidget(
          isLoading: true,
          onSearch: () {
            searchCalled = true;
          },
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton));

      expect(button.onPressed, isNull);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      expect(searchCalled, isFalse);
    });

    testWidgets('does not submit search while loading', (
      WidgetTester tester,
    ) async {
      var searchCalled = false;

      await tester.pumpWidget(
        createWidget(
          isLoading: true,
          onSearch: () {
            searchCalled = true;
          },
        ),
      );

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.testTextInput.receiveAction(TextInputAction.search);

      expect(searchCalled, isFalse);
    });
  });
}
