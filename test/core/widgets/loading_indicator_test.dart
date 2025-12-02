import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/widgets/loading_indicator.dart';
import 'widget_test_helpers.dart';

void main() {
  group('LoadingIndicator', () {
    testWidgets('displays loading spinner', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: const LoadingIndicator(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays default loading text when no message provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: const LoadingIndicator(),
        ),
      );

      await tester.pump();

      // The widget should display loading text from localization
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays custom message when provided',
        (WidgetTester tester) async {
      const customMessage = 'Loading tasks...';

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: const LoadingIndicator(message: customMessage),
        ),
      );

      expect(find.text(customMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered on screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: const LoadingIndicator(),
        ),
      );

      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      final centerWidget = tester.widget<Center>(centerFinder);
      expect(centerWidget.child, isA<Column>());
    });
  });
}

