import 'package:equatable/equatable.dart';

/// Domain entity representing a project in the Todoist system.
///
/// A project is a container for tasks and sections. Projects can be
/// organized hierarchically and have various settings for visibility,
/// access control, and organization.
class Project extends Equatable {
  /// The unique identifier of the project.
  final String id;
  
  /// Whether tasks can be assigned to users in this project.
  final bool canAssignTasks;
  
  /// The order of this project among its siblings.
  final int childOrder;
  
  /// The color associated with this project (hex code or color name).
  final String color;
  
  /// The UID of the user who created this project.
  final String creatorUid;
  
  /// The timestamp when this project was created.
  final DateTime createdAt;
  
  /// Whether this project is archived.
  final bool isArchived;
  
  /// Whether this project has been deleted.
  final bool isDeleted;
  
  /// Whether this project is marked as a favorite.
  final bool isFavorite;
  
  /// Whether this project is frozen (locked from modifications).
  final bool isFrozen;
  
  /// The name of the project.
  final String name;
  
  /// The timestamp when this project was last updated.
  final DateTime updatedAt;
  
  /// The view style for this project (e.g., "list", "board").
  final String viewStyle;
  
  /// The default sort order for tasks in this project.
  final int defaultOrder;
  
  /// The description of the project.
  final String description;
  
  /// Whether this project has public access enabled.
  final bool publicAccess;
  
  /// The public key for sharing this project, if applicable.
  final String publicKey;
  
  /// The access configuration for this project.
  final ProjectAccess access;
  
  /// The role of the current user in this project.
  final String role;
  
  /// The ID of the parent project, if this is a subproject.
  final String? parentId;
  
  /// Whether this is the inbox project.
  final bool inboxProject;
  
  /// Whether this project is collapsed in the UI.
  final bool isCollapsed;
  
  /// Whether this project is shared with other users.
  final bool isShared;

  const Project({
    required this.id,
    required this.canAssignTasks,
    required this.childOrder,
    required this.color,
    required this.creatorUid,
    required this.createdAt,
    required this.isArchived,
    required this.isDeleted,
    required this.isFavorite,
    required this.isFrozen,
    required this.name,
    required this.updatedAt,
    required this.viewStyle,
    required this.defaultOrder,
    required this.description,
    required this.publicAccess,
    required this.publicKey,
    required this.access,
    required this.role,
    this.parentId,
    required this.inboxProject,
    required this.isCollapsed,
    required this.isShared,
  });

  @override
  List<Object?> get props => [
    id,
    canAssignTasks,
    childOrder,
    color,
    creatorUid,
    createdAt,
    isArchived,
    isDeleted,
    isFavorite,
    isFrozen,
    name,
    updatedAt,
    viewStyle,
    defaultOrder,
    description,
    publicAccess,
    publicKey,
    access,
    role,
    parentId,
    inboxProject,
    isCollapsed,
    isShared,
  ];
}

/// Represents the access configuration for a project.
///
/// This includes visibility settings and additional configuration
/// for how the project can be accessed and shared.
class ProjectAccess extends Equatable {
  /// The visibility level of the project (e.g., "private", "public").
  final String visibility;
  
  /// Additional configuration parameters for project access.
  final Map<String, dynamic> configuration;

  /// Creates a [ProjectAccess] instance.
  const ProjectAccess({required this.visibility, required this.configuration});

  @override
  List<Object?> get props => [visibility, configuration];
}
