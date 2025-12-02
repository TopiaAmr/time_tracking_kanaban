import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/network/todoist_api.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Implementation of [TasksRepository] that uses the Todoist API.
///
/// This implementation communicates with the Todoist REST API to perform
/// all task, project, and section operations. It handles error conversion
/// from [DioException] to domain [Failure] types.
@Injectable(as: TasksRepository)
class TasksRepositoryImpl implements TasksRepository {
  /// The Todoist API client to use for network requests.
  final TodoistApi api;

  /// Creates a [TasksRepositoryImpl] with the given [api] client.
  TasksRepositoryImpl(this.api);

  @override
  Future<Result<List<Task>>> getTasks({
    String? projectId,
    String? sectionId,
  }) async {
    try {
      final models = await api.getTasks(
        projectId: projectId,
        sectionId: sectionId,
      );
      return Success(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    try {
      // Note: The API doesn't have a getTask endpoint, so we'll need to get all tasks and filter
      // Or this might need to be implemented differently based on actual API
      final tasks = await api.getTasks();
      final task = tasks.firstWhere((t) => t.id == id);
      return Success(task.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Task>> createTask(Task task) async {
    try {
      final body = AddTaskBody(
        content: task.content,
        description: task.description,
        projectId: task.projectId,
        sectionId: task.sectionId,
        labels: task.labels,
        priority: task.priority,
        dueDate: task.due?.toIso8601String().split('T').first,
      );
      final model = await api.addTask(body);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    try {
      final body = UpdateTaskBody(
        content: task.content,
        description: task.description,
        labels: task.labels,
        dueDate: task.due?.toIso8601String().split('T').first,
      );
      final model = await api.updateTask(task.id, body);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Task>> moveTask(
    Task task,
    String projectId,
    String sectionId,
  ) async {
    try {
      final body = MoveTaskBody(projectId: projectId, sectionId: sectionId);
      final model = await api.moveTask(task.id, body);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    try {
      await api.deleteTask(id);
      return const Success(null);
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<void>> closeTask(String id) async {
    try {
      await api.closeTask(id);
      return const Success(null);
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<List<Project>>> getProjects() async {
    try {
      final models = await api.getProjects();
      return Success(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Project>> getProject(String id) async {
    try {
      final model = await api.getProject(id);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<List<Section>>> getSections({String? projectId}) async {
    try {
      final models = await api.getSections(projectId: projectId);
      return Success(models.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }

  @override
  Future<Result<Section>> getSection(String id) async {
    try {
      final model = await api.getSection(id);
      return Success(model.toEntity());
    } on DioException catch (e) {
      return Error(ServerFailure([e.message, e.response?.statusCode]));
    } catch (e) {
      return Error(NetworkFailure([e.toString()]));
    }
  }
}
