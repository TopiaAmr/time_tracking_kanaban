import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/core/network/todoist_response_interceptor.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';

/// Integration tests for TodoistApi that make actual API calls.
///
/// These tests require:
/// - USE_REAL_API=true in the .env file to enable real API tests
/// - A valid TODOIST_API_TOKEN in the .env file
/// - A valid PROJECT_ID in the .env file (optional, for project-specific tests)
/// - An active internet connection
///
/// To run only integration tests:
/// ```bash
/// flutter test test/features/tasks/data/datasources/todoist_api_integration_test.dart
/// ```
///
/// To skip integration tests (use mock data only):
/// Set USE_REAL_API=false in your .env file
void main() {
  TodoistApi? api;
  String? projectId;
  String? createdTaskId;
  bool useRealApi = false;
  final Logger logger = Logger();

  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Check if real API tests are enabled
    final useRealApiStr = dotenv.env['USE_REAL_API'] ?? 'false';
    useRealApi = useRealApiStr.toLowerCase() == 'true';

    if (!useRealApi) {
      // Skip all tests if USE_REAL_API is false
      return;
    }

    // Verify API token is set
    final apiToken = dotenv.env['TODOIST_API_TOKEN'];
    if (apiToken == null ||
        apiToken.isEmpty ||
        apiToken == 'your_todoist_api_token_here') {
      throw Exception(
        'TODOIST_API_TOKEN is not set in .env file. '
        'Please set a valid Todoist API token to run integration tests.',
      );
    }

    // Get project ID (optional)
    projectId = dotenv.env['PROJECT_ID'];

    // Create a real Dio instance with the actual token
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.todoist.com',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
      ),
    );
    // Add interceptor to handle paginated responses
    dio.interceptors.add(TodoistResponseInterceptor());

    api = TodoistApi(dio);
  });

  tearDownAll(() async {
    // Clean up: Delete any tasks/sections created during tests
    if (createdTaskId != null && api != null) {
      try {
        await api!.deleteTask(createdTaskId!);
      } catch (e) {
        // Ignore cleanup errors
        logger.w('Warning: Failed to cleanup task $createdTaskId: $e');
      }
    }
  });

  group('Integration Tests - Real API Calls', () {
    // Helper function to check if test should be skipped
    bool shouldSkipTest() {
      return !useRealApi || api == null;
    }

    test('should get all projects from the API', () async {
      if (shouldSkipTest()) return;
      // act
      try {
        final projects = await api!.getProjects();

        // assert
        expect(projects, isA<List>());
        expect(
          projects.isNotEmpty,
          true,
          reason: 'Should have at least one project',
        );

        // Verify project structure
        final firstProject = projects.first;
        expect(firstProject.id, isNotEmpty);
        expect(firstProject.name, isNotEmpty);
        logger.d('✓ Found ${projects.length} projects');
        logger.d('  First project: ${firstProject.name} (${firstProject.id})');
      } on DioException catch (e) {
        logger.e('❌ Error getting projects:');
        logger.e('   Status: ${e.response?.statusCode}');
        logger.e('   Data: ${e.response?.data}');
        logger.e('   Headers: ${e.response?.headers}');
        logger.e(
          '   Request: ${e.requestOptions.method} ${e.requestOptions.path}',
        );
        rethrow;
      }
    });

    test('should get a specific project by ID', () async {
      if (shouldSkipTest()) return;
      // arrange
      final projects = await api!.getProjects();
      expect(
        projects.isNotEmpty,
        true,
        reason: 'Need at least one project for this test',
      );
      final testProjectId = projects.first.id;

      // act
      final project = await api!.getProject(testProjectId);

      // assert
      expect(project.id, testProjectId);
      expect(project.name, isNotEmpty);
      logger.d('✓ Retrieved project: ${project.name}');
    });

    test('should get sections from the API', () async {
      if (shouldSkipTest()) return;
      // act
      final sections = await api!.getSections();

      // assert
      expect(sections, isA<List>());
      logger.d('✓ Found ${sections.length} sections');

      if (sections.isNotEmpty) {
        final firstSection = sections.first;
        expect(firstSection.id, isNotEmpty);
        expect(firstSection.name, isNotEmpty);
        logger.d('  First section: ${firstSection.name} (${firstSection.id})');
      }
    });

    test('should get sections filtered by project ID', () async {
      if (shouldSkipTest()) return;
      // arrange
      if (projectId == null || projectId!.isEmpty) {
        // Skip if PROJECT_ID is not set
        logger.w('⚠ Skipping test: PROJECT_ID not set in .env');
        return;
      }

      // act
      final sections = await api!.getSections(projectId: projectId);

      // assert
      expect(sections, isA<List>());
      if (sections.isNotEmpty) {
        expect(sections.every((s) => s.projectId == projectId), true);
        logger.d('✓ Found ${sections.length} sections for project $projectId');
      } else {
        logger.d('✓ No sections found for project $projectId (this is okay)');
      }
    });

    test('should get tasks from the API', () async {
      if (shouldSkipTest()) return;
      // act
      final tasks = await api!.getTasks();

      // assert
      expect(tasks, isA<List>());
      logger.d('✓ Found ${tasks.length} tasks');

      if (tasks.isNotEmpty) {
        final firstTask = tasks.first;
        expect(firstTask.id, isNotEmpty);
        expect(firstTask.content, isNotEmpty);
        logger.d('  First task: ${firstTask.content} (${firstTask.id})');
      }
    });

    test('should get tasks filtered by project ID', () async {
      if (shouldSkipTest()) return;
      // arrange
      if (projectId == null || projectId!.isEmpty) {
        // Skip if PROJECT_ID is not set
        logger.w('⚠ Skipping test: PROJECT_ID not set in .env');
        return;
      }

      // act
      final tasks = await api!.getTasks(projectId: projectId);

      // assert
      expect(tasks, isA<List>());
      if (tasks.isNotEmpty) {
        expect(tasks.every((t) => t.projectId == projectId), true);
        logger.d('✓ Found ${tasks.length} tasks for project $projectId');
      } else {
        logger.d('✓ No tasks found for project $projectId (this is okay)');
      }
    });

    test(
      'should create a new task via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange
        final taskBody = AddTaskBody(
          content:
              'Integration Test Task - ${DateTime.now().millisecondsSinceEpoch}',
          description: 'This is a test task created by integration tests',
          projectId: projectId,
        );

        // act
        final createdTask = await api!.addTask(taskBody);

        // assert
        expect(createdTask.id, isNotEmpty);
        expect(createdTask.content, taskBody.content);
        expect(createdTask.description, taskBody.description);
        if (projectId != null) {
          expect(createdTask.projectId, projectId);
        }

        createdTaskId = createdTask.id;
        logger.d('✓ Created task: ${createdTask.content} (${createdTask.id})');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should get a specific task by ID',
      () async {
        if (shouldSkipTest()) return;
        // arrange
        if (createdTaskId == null) {
          // Create a task first if we don't have one
          final taskBody = AddTaskBody(
            content:
                'Test Task for Get - ${DateTime.now().millisecondsSinceEpoch}',
            projectId: projectId,
          );
          final createdTask = await api!.addTask(taskBody);
          createdTaskId = createdTask.id;
        }

        // act
        final task = await api!.getTask(createdTaskId!);

        // assert
        expect(task.id, createdTaskId);
        expect(task.content, isNotEmpty);
        expect(task.projectId, isNotEmpty);
        logger.d('✓ Retrieved task: ${task.content} (${task.id})');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test('should update a task via API', () async {
      if (shouldSkipTest()) return;
      // arrange
      if (createdTaskId == null) {
        // Create a task first if we don't have one
        final taskBody = AddTaskBody(
          content:
              'Test Task for Update - ${DateTime.now().millisecondsSinceEpoch}',
          projectId: projectId,
        );
        final createdTask = await api!.addTask(taskBody);
        createdTaskId = createdTask.id;
      }

      final updateBody = UpdateTaskBody(
        content:
            'Updated Task Content - ${DateTime.now().millisecondsSinceEpoch}',
        description: 'Updated description',
        labels: [], // Explicitly set to empty array to avoid null
      );

      // act
      final updatedTask = await api!.updateTask(createdTaskId!, updateBody);

      // assert
      expect(updatedTask.id, createdTaskId);
      expect(updatedTask.content, updateBody.content);
      expect(updatedTask.description, updateBody.description);
      logger.d('✓ Updated task: ${updatedTask.content}');
    }, timeout: const Timeout(Duration(seconds: 30)));

    test(
      'should close (complete) a task via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange
        if (createdTaskId == null) {
          // Create a task first if we don't have one
          final taskBody = AddTaskBody(
            content:
                'Test Task for Close - ${DateTime.now().millisecondsSinceEpoch}',
            projectId: projectId,
          );
          final createdTask = await api!.addTask(taskBody);
          createdTaskId = createdTask.id;
        }

        // act
        await api!.closeTask(createdTaskId!);

        // assert - verify task is completed
        final task = await api!.getTask(createdTaskId!);
        expect(
          task.checked,
          true,
          reason: 'Task should be marked as completed',
        );
        logger.d('✓ Closed task: ${task.content}');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should move a task to a different project/section via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange
        if (projectId == null || projectId!.isEmpty) {
          logger.w('⚠ Skipping test: PROJECT_ID not set in .env');
          return;
        }

        // Create a task first
        final taskBody = AddTaskBody(
          content:
              'Test Task for Move - ${DateTime.now().millisecondsSinceEpoch}',
          projectId: projectId,
        );
        final createdTask = await api!.addTask(taskBody);
        final taskIdToMove = createdTask.id;

        // Get sections for the project
        final sections = await api!.getSections(projectId: projectId);
        final targetSectionId = sections.isNotEmpty ? sections.first.id : null;

        final moveBody = MoveTaskBody(
          projectId: projectId,
          sectionId: targetSectionId,
        );

        // act
        final movedTask = await api!.moveTask(taskIdToMove, moveBody);

        // assert
        expect(movedTask.id, taskIdToMove);
        expect(movedTask.projectId, projectId);
        if (targetSectionId != null) {
          expect(movedTask.sectionId, targetSectionId);
        }
        logger.d(
          '✓ Moved task to project $projectId${targetSectionId != null ? ' and section $targetSectionId' : ''}',
        );

        // Cleanup
        await api!.deleteTask(taskIdToMove);
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test('should delete a task via API', () async {
      if (shouldSkipTest()) return;
      // arrange - create a task to delete
      final taskBody = AddTaskBody(
        content:
            'Test Task for Delete - ${DateTime.now().millisecondsSinceEpoch}',
        projectId: projectId,
      );
      final createdTask = await api!.addTask(taskBody);
      final taskIdToDelete = createdTask.id;

      // act
      await api!.deleteTask(taskIdToDelete);

      // assert - verify task is deleted
      // Note: The API might return 204 for delete, and the task might still be
      // accessible briefly. We'll verify by checking if it's marked as deleted
      // or by waiting a moment and checking again.
      await Future.delayed(const Duration(seconds: 1));
      try {
        final task = await api!.getTask(taskIdToDelete);
        // If task is retrieved, check if it's marked as deleted
        if (task.isDeleted) {
          logger.d('✓ Task marked as deleted: $taskIdToDelete');
        } else {
          // Try one more time after a delay
          await Future.delayed(const Duration(seconds: 2));
          try {
            await api!.getTask(taskIdToDelete);
            fail('Task should have been deleted');
          } on DioException catch (e) {
            if (e.response?.statusCode == 404) {
              logger.d('✓ Deleted task: $taskIdToDelete');
            } else {
              rethrow;
            }
          }
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          logger.d('✓ Deleted task: $taskIdToDelete');
        } else {
          rethrow;
        }
      }
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

