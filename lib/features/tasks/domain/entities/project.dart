import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final bool canAssignTasks;
  final int childOrder;
  final String color;
  final String creatorUid;
  final DateTime createdAt;
  final bool isArchived;
  final bool isDeleted;
  final bool isFavorite;
  final bool isFrozen;
  final String name;
  final DateTime updatedAt;
  final String viewStyle;
  final int defaultOrder;
  final String description;
  final bool publicAccess;
  final String publicKey;
  final ProjectAccess access;
  final String role;
  final String? parentId;
  final bool inboxProject;
  final bool isCollapsed;
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

class ProjectAccess extends Equatable {
  final String visibility;
  final Map<String, dynamic> configuration;

  const ProjectAccess({required this.visibility, required this.configuration});

  @override
  List<Object?> get props => [visibility, configuration];
}
