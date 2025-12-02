import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:time_tracking_kanaban/core/network/todoist_api.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/project_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/section_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late TodoistApi api;

  setUp(() {
    dio = Dio();
    dioAdapter = DioAdapter(dio: dio);
    dio.httpClientAdapter = dioAdapter;
    api = TodoistApi(dio);
  });

  group('Projects', () {
    test('getProjects should return a list of projects', () async {
      // arrange
      final projectsJson = [
        {
          'id': 'project1',
          'can_assign_tasks': true,
          'child_order': 0,
          'color': 'blue',
          'creator_uid': 'user1',
          'created_at': '2024-01-01T00:00:00Z',
          'is_archived': false,
          'is_deleted': false,
          'is_favorite': false,
          'is_frozen': false,
          'name': 'Test Project',
          'updated_at': '2024-01-01T00:00:00Z',
          'view_style': 'list',
          'default_order': 0,
          'description': 'Test description',
          'public_access': false,
          'public_key': 'key123',
          'access': {'visibility': 'private', 'configuration': {}},
          'role': 'owner',
          'inbox_project': false,
          'is_collapsed': false,
          'is_shared': false,
        },
      ];

      dioAdapter.onGet(
        '/api/v1/projects',
        (server) => server.reply(200, projectsJson),
      );

      // act
      final result = await api.getProjects();

      // assert
      expect(result, isA<List<ProjectModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'project1');
      expect(result.first.name, 'Test Project');
    });

    test('getProject should return a single project by id', () async {
      // arrange
      final projectId = 'project1';
      final projectJson = {
        'id': projectId,
        'can_assign_tasks': true,
        'child_order': 0,
        'color': 'blue',
        'creator_uid': 'user1',
        'created_at': '2024-01-01T00:00:00Z',
        'is_archived': false,
        'is_deleted': false,
        'is_favorite': false,
        'is_frozen': false,
        'name': 'Test Project',
        'updated_at': '2024-01-01T00:00:00Z',
        'view_style': 'list',
        'default_order': 0,
        'description': 'Test description',
        'public_access': false,
        'public_key': 'key123',
        'access': {'visibility': 'private', 'configuration': {}},
        'role': 'owner',
        'inbox_project': false,
        'is_collapsed': false,
        'is_shared': false,
      };

      dioAdapter.onGet(
        '/api/v1/projects/$projectId',
        (server) => server.reply(200, projectJson),
      );

      // act
      final result = await api.getProject(projectId);

      // assert
      expect(result, isA<ProjectModel>());
      expect(result.id, projectId);
      expect(result.name, 'Test Project');
    });
  });

  group('Sections', () {
    test('getSections should return a list of sections', () async {
      // arrange
      final sectionsJson = [
        {
          'id': 'section1',
          'user_id': 'user1',
          'project_id': 'project1',
          'added_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
          'name': 'Test Section',
          'section_order': 0,
          'is_archived': false,
          'is_deleted': false,
          'is_collapsed': false,
        },
      ];

      dioAdapter.onGet(
        '/api/v1/sections',
        (server) => server.reply(200, sectionsJson),
      );

      // act
      final result = await api.getSections();

      // assert
      expect(result, isA<List<SectionModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'section1');
      expect(result.first.name, 'Test Section');
    });

    test('getSections with projectId should include query parameter', () async {
      // arrange
      final projectId = 'project1';
      final sectionsJson = <Map<String, dynamic>>[];

      dioAdapter.onGet(
        '/api/v1/sections',
        (server) => server.reply(200, sectionsJson),
        queryParameters: {'project_id': projectId},
      );

      // act
      final result = await api.getSections(projectId: projectId);

      // assert
      expect(result, isA<List<SectionModel>>());
      expect(result.isEmpty, true);
    });

    test('getSection should return a single section by id', () async {
      // arrange
      final sectionId = 'section1';
      final sectionJson = {
        'id': sectionId,
        'user_id': 'user1',
        'project_id': 'project1',
        'added_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'name': 'Test Section',
        'section_order': 0,
        'is_archived': false,
        'is_deleted': false,
        'is_collapsed': false,
      };

      dioAdapter.onGet(
        '/api/v1/sections/$sectionId',
        (server) => server.reply(200, sectionJson),
      );

      // act
      final result = await api.getSection(sectionId);

      // assert
      expect(result, isA<SectionModel>());
      expect(result.id, sectionId);
      expect(result.name, 'Test Section');
    });
  });

  group('Tasks', () {
    test('getTasks should return a list of tasks', () async {
      // arrange
      final tasksJson = [
        {
          'user_id': 'user1',
          'id': 'task1',
          'project_id': 'project1',
          'section_id': 'section1',
          'added_by_uid': 'user1',
          'labels': [],
          'checked': false,
          'is_deleted': false,
          'added_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
          'priority': 1,
          'child_order': 0,
          'content': 'Test Task',
          'description': 'Test description',
          'note_count': 0,
          'day_order': 0,
          'is_collapsed': false,
        },
      ];

      dioAdapter.onGet(
        '/api/v1/tasks',
        (server) => server.reply(200, tasksJson),
      );

      // act
      final result = await api.getTasks();

      // assert
      expect(result, isA<List<TaskModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'task1');
      expect(result.first.content, 'Test Task');
    });

    test('getTasks with projectId should include query parameter', () async {
      // arrange
      final projectId = 'project1';
      final tasksJson = <Map<String, dynamic>>[];

      dioAdapter.onGet(
        '/api/v1/tasks',
        (server) => server.reply(200, tasksJson),
        queryParameters: {'project_id': projectId},
      );

      // act
      final result = await api.getTasks(projectId: projectId);

      // assert
      expect(result, isA<List<TaskModel>>());
      expect(result.isEmpty, true);
    });

    test('getTasks with sectionId should include query parameter', () async {
      // arrange
      final sectionId = 'section1';
      final tasksJson = <Map<String, dynamic>>[];

      dioAdapter.onGet(
        '/api/v1/tasks',
        (server) => server.reply(200, tasksJson),
        queryParameters: {'section_id': sectionId},
      );

      // act
      final result = await api.getTasks(sectionId: sectionId);

      // assert
      expect(result, isA<List<TaskModel>>());
      expect(result.isEmpty, true);
    });

    test(
      'getTasks with both projectId and sectionId should include both query parameters',
      () async {
        // arrange
        final projectId = 'project1';
        final sectionId = 'section1';
        final tasksJson = <Map<String, dynamic>>[];

        dioAdapter.onGet(
          '/api/v1/tasks',
          (server) => server.reply(200, tasksJson),
          queryParameters: {'project_id': projectId, 'section_id': sectionId},
        );

        // act
        final result = await api.getTasks(
          projectId: projectId,
          sectionId: sectionId,
        );

        // assert
        expect(result, isA<List<TaskModel>>());
        expect(result.isEmpty, true);
      },
    );

    test('addTask should create a new task', () async {
      // arrange
      final taskBody = AddTaskBody(
        content: 'New Task',
        description: 'New task description',
        projectId: 'project1',
      );

      final expectedRequestBody = taskBody.toJson();
      final taskJson = {
        'user_id': 'user1',
        'id': 'task1',
        'project_id': 'project1',
        'section_id': 'section1',
        'added_by_uid': 'user1',
        'labels': [],
        'checked': false,
        'is_deleted': false,
        'added_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'priority': 1,
        'child_order': 0,
        'content': 'New Task',
        'description': 'New task description',
        'note_count': 0,
        'day_order': 0,
        'is_collapsed': false,
      };

      dioAdapter.onPost(
        '/api/v1/tasks',
        (server) => server.reply(200, taskJson),
        data: (data) {
          // Compare the serialized JSON strings for exact matching
          final expectedJson = jsonEncode(expectedRequestBody);
          final actualJson = data is String ? data : jsonEncode(data);
          return expectedJson == actualJson;
        },
      );

      // act
      final result = await api.addTask(taskBody);

      // assert
      expect(result, isA<TaskModel>());
      expect(result.id, 'task1');
      expect(result.content, 'New Task');
      expect(result.description, 'New task description');
    });

    test(
      'moveTask should move a task to a different project/section',
      () async {
        // arrange
        final taskId = 'task1';
        final moveBody = MoveTaskBody(
          projectId: 'project2',
          sectionId: 'section2',
        );

        final expectedRequestBody = moveBody.toJson();
        final taskJson = {
          'user_id': 'user1',
          'id': taskId,
          'project_id': 'project2',
          'section_id': 'section2',
          'added_by_uid': 'user1',
          'labels': [],
          'checked': false,
          'is_deleted': false,
          'added_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
          'priority': 1,
          'child_order': 0,
          'content': 'Test Task',
          'description': '',
          'note_count': 0,
          'day_order': 0,
          'is_collapsed': false,
        };

        dioAdapter.onPost(
          '/api/v1/tasks/$taskId/move',
          (server) => server.reply(200, taskJson),
          data: (data) {
            // Compare the serialized JSON strings for exact matching
            final expectedJson = jsonEncode(expectedRequestBody);
            final actualJson = data is String ? data : jsonEncode(data);
            return expectedJson == actualJson;
          },
        );

        // act
        final result = await api.moveTask(taskId, moveBody);

        // assert
        expect(result, isA<TaskModel>());
        expect(result.id, taskId);
        expect(result.projectId, 'project2');
        expect(result.sectionId, 'section2');
      },
    );

    test('updateTask should update an existing task', () async {
      // arrange
      final taskId = 'task1';
      final updateBody = UpdateTaskBody(
        content: 'Updated Task',
        description: 'Updated description',
      );

      final expectedRequestBody = updateBody.toJson();
      final taskJson = {
        'user_id': 'user1',
        'id': taskId,
        'project_id': 'project1',
        'section_id': 'section1',
        'added_by_uid': 'user1',
        'labels': [],
        'checked': false,
        'is_deleted': false,
        'added_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'priority': 1,
        'child_order': 0,
        'content': 'Updated Task',
        'description': 'Updated description',
        'note_count': 0,
        'day_order': 0,
        'is_collapsed': false,
      };

      dioAdapter.onPost(
        '/api/v1/tasks/$taskId',
        (server) => server.reply(200, taskJson),
        data: (data) {
          // Compare the serialized JSON strings for exact matching
          final expectedJson = jsonEncode(expectedRequestBody);
          final actualJson = data is String ? data : jsonEncode(data);
          return expectedJson == actualJson;
        },
      );

      // act
      final result = await api.updateTask(taskId, updateBody);

      // assert
      expect(result, isA<TaskModel>());
      expect(result.id, taskId);
      expect(result.content, 'Updated Task');
      expect(result.description, 'Updated description');
    });

    test('deleteTask should delete a task', () async {
      // arrange
      final taskId = 'task1';

      dioAdapter.onDelete(
        '/api/v1/tasks/$taskId',
        (server) => server.reply(204, null),
      );

      // act
      await api.deleteTask(taskId);

      // assert
      // If no exception is thrown, the test passes
      expect(true, true);
    });

    test('closeTask should close (complete) a task', () async {
      // arrange
      final taskId = 'task1';

      dioAdapter.onPost(
        '/api/v1/tasks/$taskId/close',
        (server) => server.reply(204, null),
      );

      // act
      await api.closeTask(taskId);

      // assert
      // If no exception is thrown, the test passes
      expect(true, true);
    });
  });

  group('Error Handling', () {
    test('should handle 404 errors', () async {
      // arrange
      final projectId = 'nonexistent';

      dioAdapter.onGet(
        '/api/v1/projects/$projectId',
        (server) => server.reply(404, {'error': 'Not found'}),
      );

      // act & assert
      expect(() => api.getProject(projectId), throwsA(isA<DioException>()));
    });

    test('should handle 500 errors', () async {
      // arrange
      dioAdapter.onGet(
        '/api/v1/projects',
        (server) => server.reply(500, {'error': 'Internal server error'}),
      );

      // act & assert
      expect(() => api.getProjects(), throwsA(isA<DioException>()));
    });
  });
}
