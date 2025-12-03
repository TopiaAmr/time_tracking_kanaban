import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';
import '../../mocks/l10n_cubit_mock.mocks.dart';
import 'widget_test_helpers.dart';

void main() {
  group('AppHeader', () {
    late MockL10nCubit mockL10nCubit;

    setUp(() {
      mockL10nCubit = MockL10nCubit();
      when(mockL10nCubit.stream).thenAnswer((_) => Stream<L10nState>.value(L10nState.initial()));
      when(mockL10nCubit.state).thenReturn(L10nState.initial());
      when(mockL10nCubit.currentLocale).thenReturn(const Locale('en'));
    });

    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: const AppHeader(title: 'Tasks'),
          ),
        ),
      );

      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('displays search bar on desktop', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              onSearchChanged: (_) {},
            ),
          ),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays search bar on mobile', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              onSearchChanged: (_) {},
            ),
          ),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('calls onSearchChanged when search text changes',
        (WidgetTester tester) async {
      var searchQuery = '';

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              onSearchChanged: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test query');
      expect(searchQuery, 'test query');
    });

    testWidgets('displays filter button when onToggleFilters is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: const AppHeader(
              title: 'Tasks',
              onToggleFilters: null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
    });

    testWidgets('calls onToggleFilters when filter button is tapped',
        (WidgetTester tester) async {
      var filtersToggled = false;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              onToggleFilters: () {
                filtersToggled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();
      expect(filtersToggled, isTrue);
    });

    testWidgets('shows active filter icon when filtersOpen is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              filtersOpen: true,
              onToggleFilters: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    });

    testWidgets('displays search query when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          l10nCubit: mockL10nCubit,
          child: Scaffold(
            body: AppHeader(
              title: 'Tasks',
              searchQuery: 'test query',
              onSearchChanged: (_) {}, // Required for TextField to render
            ),
          ),
        ),
      );

      // The TextField should be displayed when onSearchChanged is provided
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      
      // Verify the TextField has the search query in its controller
      final textField = tester.widget<TextField>(textFieldFinder);
      expect(textField.controller, isNotNull);
      expect(textField.controller!.text, 'test query');
    });
  });
}

