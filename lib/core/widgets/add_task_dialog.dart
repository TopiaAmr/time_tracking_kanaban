import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Dialog for creating a new task.
class AddTaskDialog extends StatefulWidget {
  /// Default project ID to use for the new task.
  final String defaultProjectId;

  /// Default section ID to use for the new task (optional).
  final String? defaultSectionId;

  /// Callback when task is created.
  final Function(Task) onCreateTask;

  const AddTaskDialog({
    super.key,
    required this.defaultProjectId,
    this.defaultSectionId,
    required this.onCreateTask,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  final int _priority = 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() {
        _selectedDueDate = selected;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      HapticService.mediumImpact();

      // Create a task with required fields
      // Note: The backend will set userId, id, and addedByUid when creating
      // For now, we'll use placeholder values that will be replaced after creation
      final now = DateTime.now();
      final newTask = Task(
        userId: 'placeholder', // Will be set by backend
        id: 'temp-${now.millisecondsSinceEpoch}', // Will be replaced by backend
        projectId: widget.defaultProjectId,
        sectionId: widget.defaultSectionId ?? '',
        addedByUid: 'placeholder', // Will be set by backend
        labels: const [],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: _priority,
        childOrder: 0,
        content: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
        due: _selectedDueDate,
      );

      widget.onCreateTask(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.addTask,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Task title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.taskTitle,
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Task description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: context.l10n.taskDescription,
                  hintText: 'Enter task description (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Due date
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDueDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _selectedDueDate == null
                            ? context.l10n.taskDueDate
                            : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                      ),
                    ),
                  ),
                  if (_selectedDueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                      tooltip: 'Clear',
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.taskCancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: Text(context.l10n.addTask),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
