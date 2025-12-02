import 'package:equatable/equatable.dart';

class Section extends Equatable {
  final String id;
  final String userId;
  final String projectId;
  final DateTime addedAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final String name;
  final int sectionOrder;
  final bool isArchived;
  final bool isDeleted;
  final bool isCollapsed;

  const Section({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.addedAt,
    required this.updatedAt,
    this.archivedAt,
    required this.name,
    required this.sectionOrder,
    required this.isArchived,
    required this.isDeleted,
    required this.isCollapsed,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    projectId,
    addedAt,
    updatedAt,
    archivedAt,
    name,
    sectionOrder,
    isArchived,
    isDeleted,
    isCollapsed,
  ];
}
