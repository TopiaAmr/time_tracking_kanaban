import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';

/// Right filter sidebar for filtering tasks.
///
/// Responsive: Adapts for mobile (bottom sheet) and desktop (sidebar)
class FilterSidebar extends StatelessWidget {
  /// Selected date range option.
  final String? selectedDateRange;

  /// Callback when date range changes.
  final ValueChanged<String>? onDateRangeChanged;

  /// List of assigned user IDs.
  final List<String>? assignedUsers;

  /// Selected assigned user IDs.
  final List<String>? selectedAssignedUsers;

  /// Callback when assigned users change.
  final ValueChanged<List<String>>? onAssignedUsersChanged;

  /// Selected company.
  final String? selectedCompany;

  /// Callback when company changes.
  final ValueChanged<String>? onCompanyChanged;

  /// Selected task type.
  final String? selectedTaskType;

  /// Callback when task type changes.
  final ValueChanged<String>? onTaskTypeChanged;

  /// Callback to clear all filters.
  final VoidCallback? onClearFilters;

  const FilterSidebar({
    super.key,
    this.selectedDateRange,
    this.onDateRangeChanged,
    this.assignedUsers,
    this.selectedAssignedUsers,
    this.onAssignedUsersChanged,
    this.selectedCompany,
    this.onCompanyChanged,
    this.selectedTaskType,
    this.onTaskTypeChanged,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Container(
      constraints: BoxConstraints(
        minWidth: isMobile ? 0 : 280,
        maxWidth: isMobile ? double.infinity : 600,
      ),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final hasSpace = constraints.maxWidth > 300;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.filters,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onClearFilters != null && hasSpace)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextButton(
                          onPressed: onClearFilters,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text(
                            context.l10n.clearFilter,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Filter sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Date Range
                _FilterSection(
                  title: context.l10n.filterDateRange,
                  onClear: () => onDateRangeChanged?.call('all'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioOption(
                        label: context.l10n.filterLastWeek,
                        value: 'last_week',
                        groupValue: selectedDateRange,
                        onChanged: (value) =>
                            onDateRangeChanged?.call(value ?? 'all'),
                      ),
                      _RadioOption(
                        label: context.l10n.filterLastMonth,
                        value: 'last_month',
                        groupValue: selectedDateRange,
                        onChanged: (value) =>
                            onDateRangeChanged?.call(value ?? 'all'),
                      ),
                      _RadioOption(
                        label: context.l10n.filterAllTime,
                        value: 'all',
                        groupValue: selectedDateRange,
                        onChanged: (value) =>
                            onDateRangeChanged?.call(value ?? 'all'),
                      ),
                      _RadioOption(
                        label: context.l10n.filterSpecificDateRange,
                        value: 'specific',
                        groupValue: selectedDateRange,
                        onChanged: (value) =>
                            onDateRangeChanged?.call(value ?? 'all'),
                      ),
                      if (selectedDateRange == 'specific') ...[
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            hintText: '24/07/23 - 30/07/23',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Assigned to
                if (assignedUsers != null)
                  _FilterSection(
                    title: context.l10n.filterAssignedTo,
                    onClear: () => onAssignedUsersChanged?.call([]),
                    child: Column(
                      children: assignedUsers!.map((user) {
                        return _CheckboxOption(
                          label: user,
                          value: selectedAssignedUsers?.contains(user) ?? false,
                          onChanged: (checked) {
                            final current = List<String>.from(
                              selectedAssignedUsers ?? [],
                            );
                            if (checked) {
                              current.add(user);
                            } else {
                              current.remove(user);
                            }
                            onAssignedUsersChanged?.call(current);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // Company
                _FilterSection(
                  title: context.l10n.filterCompany,
                  onClear: () => onCompanyChanged?.call(''),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioOption(
                        label: 'Acme Inc',
                        value: 'acme',
                        groupValue: selectedCompany,
                        onChanged: (value) =>
                            onCompanyChanged?.call(value ?? ''),
                      ),
                      _RadioOption(
                        label: 'Horizon Group',
                        value: 'horizon',
                        groupValue: selectedCompany,
                        onChanged: (value) =>
                            onCompanyChanged?.call(value ?? ''),
                      ),
                      _RadioOption(
                        label: 'Frontier Technology',
                        value: 'frontier',
                        groupValue: selectedCompany,
                        onChanged: (value) =>
                            onCompanyChanged?.call(value ?? ''),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Task Type
                _FilterSection(
                  title: context.l10n.filterTaskType,
                  onClear: () => onTaskTypeChanged?.call(''),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RadioOption(
                        label: 'Entity',
                        value: 'entity',
                        groupValue: selectedTaskType,
                        onChanged: (value) =>
                            onTaskTypeChanged?.call(value ?? ''),
                      ),
                      _RadioOption(
                        label: 'Documents',
                        value: 'documents',
                        groupValue: selectedTaskType,
                        onChanged: (value) =>
                            onTaskTypeChanged?.call(value ?? ''),
                      ),
                      _RadioOption(
                        label: 'Finance',
                        value: 'finance',
                        groupValue: selectedTaskType,
                        onChanged: (value) =>
                            onTaskTypeChanged?.call(value ?? ''),
                      ),
                      _RadioOption(
                        label: 'Legal',
                        value: 'legal',
                        groupValue: selectedTaskType,
                        onChanged: (value) =>
                            onTaskTypeChanged?.call(value ?? ''),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClear;

  const _FilterSection({
    required this.title,
    required this.child,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final hasSpace = constraints.maxWidth > 250;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClear != null && hasSpace)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: TextButton(
                      onPressed: onClear,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(
                        context.l10n.clearFilter,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return ListTile(
      title: Text(label, overflow: TextOverflow.ellipsis),
      leading: SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(
          value: isSelected,
          onChanged: (_) => onChanged(value),
          shape: const CircleBorder(),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: () => onChanged(value),
    );
  }
}

class _CheckboxOption extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckboxOption({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CheckboxListTile(
      title: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              label.isNotEmpty ? label[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
      value: value,
      onChanged: (checked) => onChanged(checked ?? false),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
