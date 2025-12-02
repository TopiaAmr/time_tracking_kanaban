import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/section_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';

void main() {
  group('SectionModel', () {
    final now = DateTime.now();
    final sectionModelJson = {
      'id': 'section1',
      'user_id': 'user1',
      'project_id': 'project1',
      'added_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'archived_at': null,
      'name': 'Test Section',
      'section_order': 0,
      'is_archived': false,
      'is_deleted': false,
      'is_collapsed': false,
    };

    test('should create SectionModel from JSON', () {
      final model = SectionModel.fromJson(sectionModelJson);

      expect(model.id, 'section1');
      expect(model.userId, 'user1');
      expect(model.projectId, 'project1');
      expect(model.name, 'Test Section');
      expect(model.sectionOrder, 0);
      expect(model.isArchived, false);
      expect(model.isDeleted, false);
      expect(model.isCollapsed, false);
      expect(model.archivedAt, isNull);
    });

    test('should convert SectionModel to JSON', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Test Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      );

      final json = model.toJson();

      expect(json['id'], 'section1');
      expect(json['user_id'], 'user1');
      expect(json['project_id'], 'project1');
      expect(json['name'], 'Test Section');
      expect(json['section_order'], 0);
      expect(json['is_archived'], false);
      expect(json['is_deleted'], false);
      expect(json['is_collapsed'], false);
    });

    test('should convert SectionModel to Section entity', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Test Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      );

      final entity = model.toEntity();

      expect(entity, isA<Section>());
      expect(entity.id, 'section1');
      expect(entity.userId, 'user1');
      expect(entity.projectId, 'project1');
      expect(entity.name, 'Test Section');
      expect(entity.sectionOrder, 0);
      expect(entity.isArchived, false);
      expect(entity.isDeleted, false);
      expect(entity.isCollapsed, false);
    });

    test('should handle archived section', () {
      final archivedAt = DateTime.now();
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: archivedAt,
        name: 'Archived Section',
        sectionOrder: 0,
        isArchived: true,
        isDeleted: false,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.isArchived, true);
      expect(entity.archivedAt, archivedAt);
    });

    test('should handle deleted section', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Deleted Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: true,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.isDeleted, true);
    });

    test('should handle collapsed section', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Collapsed Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: true,
      );

      final entity = model.toEntity();
      expect(entity.isCollapsed, true);
    });

    test('should handle section with non-zero order', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Ordered Section',
        sectionOrder: 5,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.sectionOrder, 5);
    });

    test('should handle section without archivedAt', () {
      final model = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        archivedAt: null,
        name: 'Active Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.archivedAt, isNull);
    });
  });
}

