import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_cubit.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/l10n/supported_locales.dart';
import 'package:time_tracking_kanaban/core/theme/app_colors.dart';
import 'package:time_tracking_kanaban/core/theme/theme_cubit.dart';
import 'package:time_tracking_kanaban/core/theme/theme_state.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';

/// Settings screen with theme toggle and locale picker.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPath: '/settings',
      header: AppHeader(
        title: context.l10n.settingsTitle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme section
            Text(
              context.l10n.settingsTheme,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SegmentedButton<ThemeModeType>(
                      segments: [
                        ButtonSegment<ThemeModeType>(
                          value: ThemeModeType.light,
                          label: Text(context.l10n.settingsLightMode),
                        ),
                        ButtonSegment<ThemeModeType>(
                          value: ThemeModeType.dark,
                          label: Text(context.l10n.settingsDarkMode),
                        ),
                      ],
                      selected: {state.themeMode},
                      onSelectionChanged: (Set<ThemeModeType> selection) {
                        if (selection.isNotEmpty) {
                          context.read<ThemeCubit>().changeThemeMode(selection.first);
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Color customization section
            Text(
              context.l10n.settingsColors,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, state) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary color
                        _ColorPickerRow(
                          label: context.l10n.settingsPrimaryColor,
                          currentColor: state.customPrimaryColor ?? AppColors.accentBlue,
                          onColorSelected: (color) {
                            context.read<ThemeCubit>().updatePrimaryColor(color);
                          },
                          onReset: state.customPrimaryColor != null
                              ? () {
                                  context.read<ThemeCubit>().updatePrimaryColor(null);
                                }
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Secondary color
                        _ColorPickerRow(
                          label: context.l10n.settingsSecondaryColor,
                          currentColor: state.customSecondaryColor ?? AppColors.accentPurple,
                          onColorSelected: (color) {
                            context.read<ThemeCubit>().updateSecondaryColor(color);
                          },
                          onReset: state.customSecondaryColor != null
                              ? () {
                                  context.read<ThemeCubit>().updateSecondaryColor(null);
                                }
                              : null,
                        ),
                        const SizedBox(height: 24),
                        // Accent colors
                        Text(
                          context.l10n.settingsAccentColors,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _AccentColorChip(
                              label: context.l10n.settingsAccentBlue,
                              color: AppColors.accentBlue,
                              currentColor: state.customAccentColors?.blue,
                              onColorSelected: (color) {
                                context.read<ThemeCubit>().updateAccentColor(blue: color);
                              },
                              onReset: state.customAccentColors?.blue != null
                                  ? () {
                                      context.read<ThemeCubit>().updateAccentColor(blue: null);
                                    }
                                  : null,
                            ),
                            _AccentColorChip(
                              label: context.l10n.settingsAccentGreen,
                              color: AppColors.accentGreen,
                              currentColor: state.customAccentColors?.green,
                              onColorSelected: (color) {
                                context.read<ThemeCubit>().updateAccentColor(green: color);
                              },
                              onReset: state.customAccentColors?.green != null
                                  ? () {
                                      context.read<ThemeCubit>().updateAccentColor(green: null);
                                    }
                                  : null,
                            ),
                            _AccentColorChip(
                              label: context.l10n.settingsAccentOrange,
                              color: AppColors.accentOrange,
                              currentColor: state.customAccentColors?.orange,
                              onColorSelected: (color) {
                                context.read<ThemeCubit>().updateAccentColor(orange: color);
                              },
                              onReset: state.customAccentColors?.orange != null
                                  ? () {
                                      context.read<ThemeCubit>().updateAccentColor(orange: null);
                                    }
                                  : null,
                            ),
                            _AccentColorChip(
                              label: context.l10n.settingsAccentPurple,
                              color: AppColors.accentPurple,
                              currentColor: state.customAccentColors?.purple,
                              onColorSelected: (color) {
                                context.read<ThemeCubit>().updateAccentColor(purple: color);
                              },
                              onReset: state.customAccentColors?.purple != null
                                  ? () {
                                      context.read<ThemeCubit>().updateAccentColor(purple: null);
                                    }
                                  : null,
                            ),
                            _AccentColorChip(
                              label: context.l10n.settingsAccentRed,
                              color: AppColors.accentRed,
                              currentColor: state.customAccentColors?.red,
                              onColorSelected: (color) {
                                context.read<ThemeCubit>().updateAccentColor(red: color);
                              },
                              onReset: state.customAccentColors?.red != null
                                  ? () {
                                      context.read<ThemeCubit>().updateAccentColor(red: null);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Reset all button
                        if (state.customPrimaryColor != null ||
                            state.customSecondaryColor != null ||
                            state.customAccentColors != null)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<ThemeCubit>().resetCustomColors();
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(context.l10n.settingsResetColors),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Language section
            Text(
              context.l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<L10nCubit, L10nState>(
              builder: (context, state) {
                return Card(
                  child: Column(
                    children: SupportedLocales.locales.map((locale) {
                      final isSelected = state.locale.languageCode == locale.languageCode;
                      return ListTile(
                        title: Text(
                          SupportedLocales.getLocaleDisplayName(locale),
                        ),
                        leading: SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (_) {
                              context.read<L10nCubit>().changeLocale(locale);
                            },
                            shape: const CircleBorder(),
                          ),
                        ),
                        onTap: () {
                          context.read<L10nCubit>().changeLocale(locale);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Row widget for color picker with label and reset button.
class _ColorPickerRow extends StatelessWidget {
  final String label;
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback? onReset;

  const _ColorPickerRow({
    required this.label,
    required this.currentColor,
    required this.onColorSelected,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => _showColorPicker(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 2,
              ),
            ),
          ),
        ),
        if (onReset != null) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: onReset,
            tooltip: 'Reset to default',
          ),
        ],
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: currentColor,
        onColorSelected: onColorSelected,
      ),
    );
  }
}

/// Accent color chip widget.
class _AccentColorChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? currentColor;
  final ValueChanged<Color> onColorSelected;
  final VoidCallback? onReset;

  const _AccentColorChip({
    required this.label,
    required this.color,
    this.currentColor,
    required this.onColorSelected,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = currentColor ?? color;
    return InkWell(
      onTap: () => _showColorPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: displayColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: displayColor,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: displayColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (onReset != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  onReset?.call();
                },
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: currentColor ?? color,
        onColorSelected: onColorSelected,
      ),
    );
  }
}

/// Color picker dialog.
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Material color palette
            _buildColorPalette(),
            const SizedBox(height: 16),
            // Custom color input
            TextField(
              decoration: InputDecoration(
                labelText: 'Hex color',
                hintText: '#RRGGBB',
                prefixText: '#',
              ),
              onChanged: (value) {
                try {
                  final color = Color(int.parse(value, radix: 16) + 0xFF000000);
                  setState(() => _selectedColor = color);
                } catch (e) {
                  // Invalid color
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.taskCancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(_selectedColor);
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.taskSave),
        ),
      ],
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = _selectedColor.toARGB32() == color.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _getContrastColor(color),
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

