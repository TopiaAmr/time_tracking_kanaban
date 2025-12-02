import 'package:equatable/equatable.dart';

/// Domain entity representing a task in the Todoist system.
///
/// A task is the fundamental unit of work in Todoist. It contains all
/// information about a single task including its content, metadata,
/// relationships, and status.
class Task extends Equatable {
  /// The ID of the user who owns this task.
  final String userId;
  
  /// The unique identifier of the task.
  final String id;
  
  /// The ID of the project this task belongs to.
  final String projectId;
  
  /// The ID of the section this task belongs to.
  final String sectionId;
  
  /// The ID of the parent task, if this is a subtask.
  final String? parentId;
  
  /// The UID of the user who added this task.
  final String addedByUid;
  
  /// The UID of the user who assigned this task, if applicable.
  final String? assignedByUid;
  
  /// The UID of the user responsible for this task, if applicable.
  final String? responsibleUid;
  
  /// List of label IDs associated with this task.
  final List<String> labels;
  
  /// The deadline for this task, if set.
  final DateTime? deadline;
  
  /// The estimated duration of this task in minutes, if set.
  final int? duration;
  
  /// Whether this task is checked (completed).
  final bool checked;
  
  /// Whether this task has been deleted.
  final bool isDeleted;
  
  /// The timestamp when this task was added.
  final DateTime addedAt;
  
  /// The timestamp when this task was completed, if applicable.
  final DateTime? completedAt;
  
  /// The UID of the user who completed this task, if applicable.
  final String? completedByUid;
  
  /// The timestamp when this task was last updated.
  final DateTime updatedAt;
  
  /// The due date for this task, if set.
  final DateTime? due;
  
  /// The priority level of this task (1-4, where 4 is highest priority).
  final int priority;
  
  /// The order of this task among its siblings.
  final int childOrder;
  
  /// The main content (title) of the task.
  final String content;
  
  /// The description/notes for this task.
  final String description;
  
  /// The number of notes/comments attached to this task.
  final int noteCount;
  
  /// The order of this task within its day view.
  final int dayOrder;
  
  /// Whether this task's subtasks are collapsed in the UI.
  final bool isCollapsed;

  const Task({
    required this.userId,
    required this.id,
    required this.projectId,
    required this.sectionId,
    this.parentId,
    required this.addedByUid,
    this.assignedByUid,
    this.responsibleUid,
    required this.labels,
    this.deadline,
    this.duration,
    required this.checked,
    required this.isDeleted,
    required this.addedAt,
    this.completedAt,
    this.completedByUid,
    required this.updatedAt,
    this.due,
    required this.priority,
    required this.childOrder,
    required this.content,
    required this.description,
    required this.noteCount,
    required this.dayOrder,
    required this.isCollapsed,
  });

  @override
  List<Object?> get props => [
    userId,
    id,
    projectId,
    sectionId,
    parentId,
    addedByUid,
    assignedByUid,
    responsibleUid,
    labels,
    deadline,
    duration,
    checked,
    isDeleted,
    addedAt,
    completedAt,
    completedByUid,
    updatedAt,
    due,
    priority,
    childOrder,
    content,
    description,
    noteCount,
    dayOrder,
    isCollapsed,
  ];
}
