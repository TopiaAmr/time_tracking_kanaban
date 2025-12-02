import 'package:equatable/equatable.dart';

/// Domain entity representing a section within a project.
///
/// Sections are used to organize tasks within a project. They provide
/// an additional level of organization beyond projects and can be used
/// to group related tasks together.
class Section extends Equatable {
  /// The unique identifier of the section.
  final String id;
  
  /// The ID of the user who owns this section.
  final String userId;
  
  /// The ID of the project this section belongs to.
  final String projectId;
  
  /// The timestamp when this section was added.
  final DateTime addedAt;
  
  /// The timestamp when this section was last updated.
  final DateTime updatedAt;
  
  /// The timestamp when this section was archived, if applicable.
  final DateTime? archivedAt;
  
  /// The name of the section.
  final String name;
  
  /// The order of this section within its project.
  final int sectionOrder;
  
  /// Whether this section is archived.
  final bool isArchived;
  
  /// Whether this section has been deleted.
  final bool isDeleted;
  
  /// Whether this section is collapsed in the UI.
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
