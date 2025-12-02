import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/core/network/todoist_response_interceptor.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';

/// Integration tests for TodoistApi comments that make actual API calls.
///
/// These tests require:
/// - USE_REAL_API=true in the .env file to enable real API tests
/// - A valid TODOIST_API_TOKEN in the .env file
/// - A valid PROJECT_ID in the .env file (optional, for project-specific tests)
/// - An active internet connection
///
/// To run only integration tests:
/// ```bash
/// flutter test test/features/tasks/data/datasources/todoist_api_comments_integration_test.dart
/// ```
///
/// To skip integration tests (use mock data only):
/// Set USE_REAL_API=false in your .env file
void main() {
  TodoistApi? api;
  String? projectId;
  String? testTaskId;
  List<String> createdCommentIds = [];
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

    // Create a test task for comments to be attached to
    if (api != null) {
      try {
        final taskBody = AddTaskBody(
          content:
              'Integration Test Task for Comments - ${DateTime.now().millisecondsSinceEpoch}',
          description: 'This is a test task created for comment integration tests',
          projectId: projectId,
        );
        final createdTask = await api!.addTask(taskBody);
        testTaskId = createdTask.id;
        logger.d('✓ Created test task for comments: ${createdTask.id}');
      } catch (e) {
        logger.e('❌ Failed to create test task: $e');
        rethrow;
      }
    }
  });

  tearDownAll(() async {
    // Clean up: Delete any comments created during tests
    if (api != null && createdCommentIds.isNotEmpty) {
      for (final commentId in createdCommentIds) {
        try {
          await api!.deleteComment(commentId);
          logger.d('✓ Cleaned up comment: $commentId');
        } catch (e) {
          // Ignore cleanup errors
          logger.w('Warning: Failed to cleanup comment $commentId: $e');
        }
      }
    }

    // Clean up: Delete the test task
    if (testTaskId != null && api != null) {
      try {
        await api!.deleteTask(testTaskId!);
        logger.d('✓ Cleaned up test task: $testTaskId');
      } catch (e) {
        // Ignore cleanup errors
        logger.w('Warning: Failed to cleanup task $testTaskId: $e');
      }
    }
  });

  group('Integration Tests - Comments API Calls', () {
    // Helper function to check if test should be skipped
    bool shouldSkipTest() {
      return !useRealApi || api == null || testTaskId == null;
    }

    test(
      'should get comments for a task (may be empty initially)',
      () async {
        if (shouldSkipTest()) return;
        // act
        try {
          final response = await api!.getComments(taskId: testTaskId!);

          // assert
          expect(response, isA<CommentsResponse>());
          expect(response.results, isA<List<CommentModel>>());
          logger.d('✓ Retrieved comments for task $testTaskId');
          logger.d('  Found ${response.results.length} comments');
        } on DioException catch (e) {
          logger.e('❌ Error getting comments:');
          logger.e('   Status: ${e.response?.statusCode}');
          logger.e('   Data: ${e.response?.data}');
          logger.e('   Headers: ${e.response?.headers}');
          logger.e(
            '   Request: ${e.requestOptions.method} ${e.requestOptions.path}',
          );
          rethrow;
        }
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should create a comment on a task via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange
        final commentBody = CreateCommentBody(
          content:
              'Integration Test Comment - ${DateTime.now().millisecondsSinceEpoch}',
          taskId: testTaskId,
        );

        // act
        final createdComment = await api!.addComment(commentBody);

        // assert
        expect(createdComment.id, isNotEmpty);
        expect(createdComment.content, commentBody.content);
        expect(createdComment.postedUid, isNotEmpty);
        expect(createdComment.postedAt, isA<DateTime>());

        // Track for cleanup
        createdCommentIds.add(createdComment.id);
        logger.d('✓ Created comment: ${createdComment.content} (${createdComment.id})');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should get comments after creating one',
      () async {
        if (shouldSkipTest()) return;
        // arrange - ensure we have at least one comment
        if (createdCommentIds.isEmpty) {
          final commentBody = CreateCommentBody(
            content:
                'Test Comment for Get - ${DateTime.now().millisecondsSinceEpoch}',
            taskId: testTaskId,
          );
          final createdComment = await api!.addComment(commentBody);
          createdCommentIds.add(createdComment.id);
        }

        // act
        final response = await api!.getComments(taskId: testTaskId!);

        // assert
        expect(response, isA<CommentsResponse>());
        expect(response.results, isA<List<CommentModel>>());
        expect(
          response.results.length,
          greaterThanOrEqualTo(1),
          reason: 'Should have at least one comment',
        );

        // Verify the created comment is in the list
        final foundComment = response.results.firstWhere(
          (c) => createdCommentIds.contains(c.id),
          orElse: () => throw Exception('Created comment not found in response'),
        );
        expect(foundComment.id, isIn(createdCommentIds));
        expect(foundComment.content, isNotEmpty);
        logger.d('✓ Retrieved ${response.results.length} comments');
        logger.d('  Found created comment: ${foundComment.content}');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should update a comment via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange - create a comment to update
        String commentIdToUpdate;
        if (createdCommentIds.isEmpty) {
          final commentBody = CreateCommentBody(
            content:
                'Test Comment for Update - ${DateTime.now().millisecondsSinceEpoch}',
            taskId: testTaskId,
          );
          final createdComment = await api!.addComment(commentBody);
          commentIdToUpdate = createdComment.id;
          createdCommentIds.add(commentIdToUpdate);
        } else {
          commentIdToUpdate = createdCommentIds.first;
        }

        final updateBody = UpdateCommentBody(
          content:
              'Updated Comment Content - ${DateTime.now().millisecondsSinceEpoch}',
        );

        // act
        final updatedComment = await api!.updateComment(commentIdToUpdate, updateBody);

        // assert
        expect(updatedComment.id, commentIdToUpdate);
        expect(updatedComment.content, updateBody.content);
        logger.d('✓ Updated comment: ${updatedComment.content}');

        // Verify the update is reflected when getting comments
        final response = await api!.getComments(taskId: testTaskId!);
        final foundComment = response.results.firstWhere(
          (c) => c.id == commentIdToUpdate,
          orElse: () => throw Exception('Updated comment not found'),
        );
        expect(foundComment.content, updateBody.content);
        logger.d('✓ Verified update is reflected in getComments');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should delete a comment via API',
      () async {
        if (shouldSkipTest()) return;
        // arrange - create a comment to delete
        final commentBody = CreateCommentBody(
          content:
              'Test Comment for Delete - ${DateTime.now().millisecondsSinceEpoch}',
          taskId: testTaskId,
        );
        final createdComment = await api!.addComment(commentBody);
        final commentIdToDelete = createdComment.id;

        // act
        await api!.deleteComment(commentIdToDelete);

        // assert - verify comment is deleted
        // Note: The API might return 204 for delete, and the comment might still be
        // accessible briefly. We'll verify by checking if it's gone from the list.
        await Future.delayed(const Duration(seconds: 1));
        final response = await api!.getComments(taskId: testTaskId!);
        final foundComment = response.results.where(
          (c) => c.id == commentIdToDelete,
        );

        expect(
          foundComment.isEmpty,
          true,
          reason: 'Deleted comment should not appear in getComments response',
        );
        logger.d('✓ Deleted comment: $commentIdToDelete');

        // Don't add to cleanup list since it's already deleted
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    test(
      'should handle multiple comments on a task',
      () async {
        if (shouldSkipTest()) return;
        // arrange - create multiple comments
        final comment1Body = CreateCommentBody(
          content:
              'First Comment - ${DateTime.now().millisecondsSinceEpoch}',
          taskId: testTaskId,
        );
        final comment2Body = CreateCommentBody(
          content:
              'Second Comment - ${DateTime.now().millisecondsSinceEpoch}',
          taskId: testTaskId,
        );

        final createdComment1 = await api!.addComment(comment1Body);
        final createdComment2 = await api!.addComment(comment2Body);

        createdCommentIds.add(createdComment1.id);
        createdCommentIds.add(createdComment2.id);

        // act
        final response = await api!.getComments(taskId: testTaskId!);

        // assert
        expect(response.results.length, greaterThanOrEqualTo(2));
        
        // Verify both comments are in the response
        final commentIds = response.results.map((c) => c.id).toList();
        expect(commentIds, contains(createdComment1.id));
        expect(commentIds, contains(createdComment2.id));
        
        logger.d('✓ Retrieved ${response.results.length} comments');
        logger.d('  Found both created comments');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}

