import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/project_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';

void main() {
  group('ProjectModel', () {
    final now = DateTime.now();
    final projectModelJson = {
      'id': 'project1',
      'can_assign_tasks': true,
      'child_order': 0,
      'color': '#FF0000',
      'creator_uid': 'user1',
      'created_at': now.toIso8601String(),
      'is_archived': false,
      'is_deleted': false,
      'is_favorite': false,
      'is_frozen': false,
      'name': 'Test Project',
      'updated_at': now.toIso8601String(),
      'view_style': 'list',
      'default_order': 0,
      'description': 'Test Description',
      'public_access': false,
      'public_key': 'public_key_123',
      'access': <String, dynamic>{
        'visibility': 'private',
        'configuration': <String, dynamic>{},
      },
      'role': 'owner',
      'parent_id': null,
      'inbox_project': false,
      'is_collapsed': false,
      'is_shared': false,
    };

    test('should create ProjectModel from JSON', () {
      final model = ProjectModel.fromJson(projectModelJson);

      expect(model.id, 'project1');
      expect(model.name, 'Test Project');
      expect(model.color, '#FF0000');
      expect(model.canAssignTasks, true);
      expect(model.isArchived, false);
      expect(model.isDeleted, false);
      expect(model.isFavorite, false);
      expect(model.isFrozen, false);
      expect(model.viewStyle, 'list');
      expect(model.description, 'Test Description');
      expect(model.publicAccess, false);
      expect(model.publicKey, 'public_key_123');
      expect(model.role, 'owner');
      expect(model.parentId, isNull);
      expect(model.inboxProject, false);
      expect(model.isCollapsed, false);
      expect(model.isShared, false);
    });

    test('should convert ProjectModel to JSON', () {
      final model = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Test Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: 'Test Description',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final json = model.toJson();

      expect(json['id'], 'project1');
      expect(json['name'], 'Test Project');
      expect(json['color'], '#FF0000');
      expect(json['can_assign_tasks'], true);
      expect(json['view_style'], 'list');
    });

    test('should convert ProjectModel to Project entity', () {
      final model = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Test Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: 'Test Description',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final entity = model.toEntity();

      expect(entity, isA<Project>());
      expect(entity.id, 'project1');
      expect(entity.name, 'Test Project');
      expect(entity.color, '#FF0000');
      expect(entity.canAssignTasks, true);
      expect(entity.viewStyle, 'list');
      expect(entity.description, 'Test Description');
      expect(entity.role, 'owner');
    });

    test('should handle archived project', () {
      final model = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: true,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Archived Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: '',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final entity = model.toEntity();
      expect(entity.isArchived, true);
    });

    test('should handle favorite project', () {
      final model = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: true,
        isFrozen: false,
        name: 'Favorite Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: '',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final entity = model.toEntity();
      expect(entity.isFavorite, true);
    });

    test('should handle project with parent (subproject)', () {
      final model = ProjectModel(
        id: 'project2',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Subproject',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: '',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: 'project1',
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final entity = model.toEntity();
      expect(entity.parentId, 'project1');
    });

    test('should handle inbox project', () {
      final model = ProjectModel(
        id: 'inbox',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Inbox',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: '',
        publicAccess: false,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: true,
        isCollapsed: false,
        isShared: false,
      );

      final entity = model.toEntity();
      expect(entity.inboxProject, true);
    });

    test('should handle shared project', () {
      final model = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: '#FF0000',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Shared Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: '',
        publicAccess: true,
        publicKey: 'public_key_123',
        access: ProjectAccessModel(
          visibility: 'public',
          configuration: {},
        ),
        role: 'owner',
        parentId: null,
        inboxProject: false,
        isCollapsed: false,
        isShared: true,
      );

      final entity = model.toEntity();
      expect(entity.isShared, true);
      expect(entity.publicAccess, true);
    });
  });

  group('ProjectAccessModel', () {
    test('should create ProjectAccessModel from JSON', () {
      final json = {
        'visibility': 'private',
        'configuration': {'key': 'value'},
      };

      final model = ProjectAccessModel.fromJson(json);

      expect(model.visibility, 'private');
      expect(model.configuration, {'key': 'value'});
    });

    test('should convert ProjectAccessModel to JSON', () {
      final model = ProjectAccessModel(
        visibility: 'public',
        configuration: {'key': 'value'},
      );

      final json = model.toJson();

      expect(json['visibility'], 'public');
      expect(json['configuration'], {'key': 'value'});
    });

    test('should convert ProjectAccessModel to ProjectAccess entity', () {
      final model = ProjectAccessModel(
        visibility: 'private',
        configuration: {'key': 'value'},
      );

      final entity = model.toEntity();

      expect(entity.visibility, 'private');
      expect(entity.configuration, {'key': 'value'});
    });

    test('should handle empty configuration', () {
      final model = ProjectAccessModel(
        visibility: 'private',
        configuration: {},
      );

      final entity = model.toEntity();
      expect(entity.configuration, isEmpty);
    });
  });
}

