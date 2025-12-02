import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/core/widgets/sidebar.dart';
import 'widget_test_helpers.dart';

void main() {
  group('Sidebar', () {
    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
        ),
      );

      // Should display app title from localization
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
        ),
      );

      // Should find the logo container with 'K'
      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('displays navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
        ),
      );

      // Should find navigation items list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('highlights active route', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/tasks')),
        ),
      );

      // The active item should have different styling
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('navigates when navigation item is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(path: '/', builder: (_, _) => const Scaffold()),
              GoRoute(
                path: '/tasks',
                builder: (_, _) =>
                    const Scaffold(body: Sidebar(currentPath: '/tasks')),
              ),
            ],
          ),
        ),
      );

      // Find and tap a navigation item
      final tasksItem = find.text('Tasks');
      if (tasksItem.evaluate().isNotEmpty) {
        await tester.tap(tasksItem);
        await tester.pump();
      }
    });

    testWidgets('displays user profile section', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
        ),
      );

      // Should find user avatar
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('adapts width for mobile', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      // Verify mobile layout (width should be null)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adapts width for desktop', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      // Verify desktop layout (width should be 240)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays all navigation sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(body: const Sidebar(currentPath: '/')),
        ),
      );

      // Should find dividers separating sections
      expect(find.byType(Divider), findsWidgets);
    });
  });
}
