import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/add_task_dialog.dart';
import 'package:time_tracking_kanaban/core/widgets/filter_sidebar.dart';
import 'package:time_tracking_kanaban/core/widgets/kanban_column.dart';
import 'package:time_tracking_kanaban/core/widgets/kanban_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/core/navigation/route_names.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_event.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_state.dart';

/// Kanban board screen displaying tasks in columns.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  String? _searchQuery;
  bool _filtersOpen = false;
  String? _selectedDateRange;
  List<String> _selectedAssignedUsers = [];
  String? _selectedCompany;
  String? _selectedTaskType;

  @override
  void initState() {
    super.initState();
    context.read<KanbanBloc>().add(const LoadKanbanTasks());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return AppScaffold(
      currentPath: '/tasks',
      header: AppHeader(
        title: context.l10n.navTasks,
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          // Search filtering - will be implemented when filter logic is added
        },
        filtersOpen: _filtersOpen,
        onToggleFilters: () {
          setState(() {
            _filtersOpen = !_filtersOpen;
          });
        },
      ),
      rightSidebar: _filtersOpen
          ? FilterSidebar(
              selectedDateRange: _selectedDateRange,
              onDateRangeChanged: (value) {
                setState(() {
                  _selectedDateRange = value;
                });
              },
              assignedUsers: const [
                'David Wilson',
                'James Davis',
                'William Anderson',
                'Daniel Taylor',
                'Robert Johnson',
              ],
              selectedAssignedUsers: _selectedAssignedUsers,
              onAssignedUsersChanged: (users) {
                setState(() {
                  _selectedAssignedUsers = users;
                });
              },
              selectedCompany: _selectedCompany,
              onCompanyChanged: (company) {
                setState(() {
                  _selectedCompany = company;
                });
              },
              selectedTaskType: _selectedTaskType,
              onTaskTypeChanged: (type) {
                setState(() {
                  _selectedTaskType = type;
                });
              },
              onClearFilters: () {
                setState(() {
                  _selectedDateRange = null;
                  _selectedAssignedUsers = [];
                  _selectedCompany = null;
                  _selectedTaskType = null;
                });
              },
            )
          : null,
      rightSidebarOpen: _filtersOpen && !isMobile,
      onToggleRightSidebar: () {
        setState(() {
          _filtersOpen = !_filtersOpen;
        });
      },
      body: BlocBuilder<KanbanBloc, KanbanState>(
        builder: (context, state) {
          if (state is KanbanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.errorUnknown,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<KanbanBloc>().add(const LoadKanbanTasks());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is KanbanLoaded) {
            return _buildKanbanBoard(context, state);
          } else {
            // KanbanInitial or KanbanLoading state - show skeleton
            return const KanbanSkeleton();
          }
        },
      ),
    );
  }

  /// Get default project ID from existing tasks.
  String? _getDefaultProjectId(KanbanLoaded state) {
    // Get project ID from any task
    for (final tasks in state.tasksBySection.values) {
      if (tasks.isNotEmpty) {
        return tasks.first.projectId;
      }
    }
    if (state.tasksWithoutSection.isNotEmpty) {
      return state.tasksWithoutSection.first.projectId;
    }
    // Get project ID from any section
    if (state.sections.isNotEmpty) {
      return state.sections.first.projectId;
    }
    return null;
  }

  /// Show add task dialog.
  void _showAddTaskDialog(BuildContext context, KanbanLoaded state) {
    final projectId = _getDefaultProjectId(state);
    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No project available. Please create a project first.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AddTaskDialog(
        defaultProjectId: projectId,
        onCreateTask: (task) {
          context.read<KanbanBloc>().add(CreateTask(task));
        },
      ),
    );
  }

  /// Handle task drop on a section column.
  void _handleTaskDrop(BuildContext context, Task task, String? sectionId) {
    HapticService.heavyImpact();

    // If task is being moved to the same section, do nothing
    if (task.sectionId == sectionId) {
      return;
    }

    // Move task to the new section
    final projectId = task.projectId;
    context.read<KanbanBloc>().add(
      MoveTaskEvent(task: task, projectId: projectId, sectionId: sectionId),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, KanbanLoaded state) {
    final isMobile = context.isMobile;

    // Sort sections by sectionOrder
    final sortedSections = List<Section>.from(state.sections)
      ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));

    // Build columns for each section
    final sectionColumns = sortedSections.map((section) {
      final tasks = state.tasksBySection[section.id] ?? [];
      return KanbanColumn(
        section: section,
        tasks: tasks,
        onTaskTap: (task) {
          context.go('${RouteNames.tasks}/${task.id}');
        },
        onTaskDropped: (task) => _handleTaskDrop(context, task, section.id),
        onAddTask: () => _showAddTaskDialog(context, state),
      );
    }).toList();

    // Add column for tasks without section if there are any
    if (state.tasksWithoutSection.isNotEmpty) {
      sectionColumns.add(
        KanbanColumn(
          section: null,
          tasks: state.tasksWithoutSection,
          onTaskTap: (task) {
            context.go('${RouteNames.tasks}/${task.id}');
          },
          onTaskDropped: (task) => _handleTaskDrop(context, task, null),
          onAddTask: () => _showAddTaskDialog(context, state),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      child: SingleChildScrollView(
        scrollDirection: isMobile ? Axis.vertical : Axis.horizontal,
        child: isMobile
            ? Column(
                children: sectionColumns
                    .map(
                      (col) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: col,
                      ),
                    )
                    .toList(),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sectionColumns,
              ),
      ),
    );
  }
}
