import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_cubit.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/l10n/supported_locales.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';

/// App header with title, search, and filters.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class AppHeader extends StatelessWidget {
  /// Page title to display.
  final String title;

  /// Search query.
  final String? searchQuery;

  /// Callback when search changes.
  final ValueChanged<String>? onSearchChanged;

  /// Optional search controller for managing text field state.
  final TextEditingController? searchController;

  /// Whether filters panel is open.
  final bool filtersOpen;

  /// Callback to toggle filters.
  final VoidCallback? onToggleFilters;

  /// Whether to show back button instead of menu button on mobile.
  final bool showBackButton;

  /// Callback when back button is pressed. If null, uses Navigator.pop.
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.searchQuery,
    this.onSearchChanged,
    this.searchController,
    this.filtersOpen = false,
    this.onToggleFilters,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              // Back button or Hamburger menu button on mobile
              if (isMobile)
                showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      )
                    : Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          tooltip: 'Menu',
                        ),
                      ),
              // Back button on desktop when showBackButton is true
              if (!isMobile && showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                // Search bar
                if (onSearchChanged != null)
                  SizedBox(
                    width: 300,
                    child: TextField(
                      onChanged: onSearchChanged,
                      controller: searchController ?? TextEditingController(text: searchQuery),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchPlaceholder,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                // Language switcher
                _LanguageSwitcher(),
                const SizedBox(width: 8),
                // Filters button
                if (onToggleFilters != null)
                  IconButton(
                    onPressed: onToggleFilters,
                    icon: Icon(
                      filtersOpen
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    tooltip: context.l10n.filters,
                  ),
              ],
            ],
          ),

          // Mobile search and filters
          if (isMobile) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onSearchChanged != null)
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      controller: searchController ?? TextEditingController(text: searchQuery),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchPlaceholder,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // Language switcher (mobile)
                _LanguageSwitcher(isCompact: true),
                if (onToggleFilters != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onToggleFilters,
                    icon: Icon(
                      filtersOpen
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    tooltip: context.l10n.filters,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Language switcher widget for quick language change.
class _LanguageSwitcher extends StatelessWidget {
  final bool isCompact;

  const _LanguageSwitcher({this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<L10nCubit, L10nState>(
      builder: (context, state) {
        final currentLocale = state.locale;
        final currentLanguageName = SupportedLocales.getLocaleDisplayName(
          currentLocale,
        );

        if (isCompact) {
          // Mobile: Icon button with dropdown
          return PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: context.l10n.settingsLanguage,
            onSelected: (locale) {
              context.read<L10nCubit>().changeLocale(locale);
            },
            itemBuilder: (context) {
              return SupportedLocales.locales.map((locale) {
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text(SupportedLocales.getLocaleDisplayName(locale)),
                    ],
                  ),
                );
              }).toList();
            },
          );
        } else {
          // Desktop: Button with language name
          return PopupMenuButton<Locale>(
            tooltip: context.l10n.settingsLanguage,
            onSelected: (locale) {
              context.read<L10nCubit>().changeLocale(locale);
            },
            itemBuilder: (context) {
              return SupportedLocales.locales.map((locale) {
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    children: [
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text(SupportedLocales.getLocaleDisplayName(locale)),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    currentLanguageName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
