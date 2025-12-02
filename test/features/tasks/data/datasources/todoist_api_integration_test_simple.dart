import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/core/network/todoist_response_interceptor.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';
import 'package:logger/logger.dart';

/// Simple integration test to verify API connection and basic functionality.
///
/// This test makes a minimal API call to verify the connection works.
///
/// To skip this test (use mock data only):
/// Set USE_REAL_API=false in your .env file
void main() {
  late TodoistApi api;
  final Logger logger = Logger();
  bool useRealApi = false;

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

    // Add interceptor to handle Todoist API v1 paginated responses
    dio.interceptors.add(TodoistResponseInterceptor());

    // Add logging interceptor to see requests/responses
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    api = TodoistApi(dio);
  });

  test(
    'should connect to Todoist API and get a single task',
    () async {
      if (!useRealApi) {
        // Skip test if real API is disabled
        return;
      }

      // First, let's try to get all tasks to find a task ID
      try {
        logger.d('\n=== Testing API Connection ===');

        // Try to get tasks
        logger.d('Attempting to get tasks...');
        final tasks = await api.getTasks();
        logger.d('✓ Successfully retrieved ${tasks.length} tasks');

        if (tasks.isNotEmpty) {
          final firstTask = tasks.first;
          logger.d('First task: ${firstTask.content} (ID: ${firstTask.id})');

          // Now try to get that specific task
          logger.d('\nAttempting to get task by ID: ${firstTask.id}');
          final task = await api.getTask(firstTask.id);
          logger.d('✓ Successfully retrieved task: ${task.content}');
          logger.d('  Project ID: ${task.projectId}');
          logger.d('  Section ID: ${task.sectionId}');
          logger.d('  Completed: ${task.checked}');
        } else {
          logger.d('⚠ No tasks found. Creating a test task...');

          // Create a test task
          final projectId = dotenv.env['PROJECT_ID'];
          final addTaskBody = AddTaskBody(
            content:
                'Integration Test Task - ${DateTime.now().millisecondsSinceEpoch}',
            description: 'This is a test task',
            projectId: projectId,
          );

          final createdTask = await api.addTask(addTaskBody);
          logger.d(
            '✓ Created task: ${createdTask.content} (ID: ${createdTask.id})',
          );

          // Get the created task
          final retrievedTask = await api.getTask(createdTask.id);
          logger.d('✓ Retrieved task: ${retrievedTask.content}');

          // Clean up
          await api.deleteTask(createdTask.id);
          logger.d('✓ Deleted test task');
        }
      } on DioException catch (e) {
        logger.d('\n❌ DioException occurred:');
        logger.d('   Status Code: ${e.response?.statusCode}');
        logger.d('   Status Message: ${e.response?.statusMessage}');
        logger.d('   Response Data: ${e.response?.data}');
        logger.d('   Request Path: ${e.requestOptions.path}');
        logger.d('   Request Method: ${e.requestOptions.method}');
        logger.d('   Request Headers: ${e.requestOptions.headers}');
        rethrow;
      } catch (e, stackTrace) {
        logger.d('\n❌ Unexpected error:');
        logger.d('   Error: $e');
        logger.d('   Stack trace: $stackTrace');
        rethrow;
      }
    },
    timeout: const Timeout(Duration(seconds: 60)),
  );
}

