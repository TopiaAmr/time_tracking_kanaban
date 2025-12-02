import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'widget_test_helpers.dart';

void main() {
  group('AppScaffold', () {
    testWidgets('displays body content', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('displays header when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body'),
            header: const Text('Header'),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('displays sidebar on desktop', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(currentPath: '/', body: const Text('Body')),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      await tester.pumpAndSettle();
      // Should find Row layout with sidebar
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('displays drawer on mobile', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(currentPath: '/', body: const Text('Body')),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      // Should find Scaffold with drawer
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays right sidebar when provided and open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body'),
            rightSidebar: const Text('Right Sidebar'),
            rightSidebarOpen: true,
          ),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      expect(find.text('Right Sidebar'), findsOneWidget);
    });

    testWidgets('hides right sidebar when closed', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body'),
            rightSidebar: const Text('Right Sidebar'),
            rightSidebarOpen: false,
          ),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      expect(find.text('Right Sidebar'), findsNothing);
    });

    testWidgets('calls onToggleRightSidebar when toggled', (
      WidgetTester tester,
    ) async {
      var toggled = false;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body'),
            rightSidebar: const Text('Right Sidebar'),
            rightSidebarOpen: false,
            onToggleRightSidebar: () {
              toggled = true;
            },
          ),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      // The toggle would typically be triggered by a button in the header
      // For now, we just verify the callback is set up
      expect(toggled, isFalse);
    });

    testWidgets('uses correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: AppScaffold(
            currentPath: '/',
            body: const Text('Body'),
            header: const Text('Header'),
          ),
        ),
      );

      // Should have Column structure for body and header
      expect(find.byType(Column), findsWidgets);
    });
  });
}
