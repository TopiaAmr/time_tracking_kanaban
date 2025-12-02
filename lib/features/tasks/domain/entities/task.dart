import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String userId;
  final String id;
  final String projectId;
  final String sectionId;
  final String? parentId;
  final String addedByUid;
  final String? assignedByUid;
  final String? responsibleUid;
  final List<String> labels;
  final DateTime? deadline;
  final int? duration;
  final bool checked;
  final bool isDeleted;
  final DateTime addedAt;
  final DateTime? completedAt;
  final String? completedByUid;
  final DateTime updatedAt;
  final DateTime? due;
  final int priority;
  final int childOrder;
  final String content;
  final String description;
  final int noteCount;
  final int dayOrder;
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
