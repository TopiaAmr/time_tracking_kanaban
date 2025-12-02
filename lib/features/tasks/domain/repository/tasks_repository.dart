import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

abstract class TasksRepository {
  Future<Result<List<Task>>> getTasks({String? projectId, String? sectionId});
  Future<Result<Task>> getTask(String id);
  Future<Result<Task>> createTask(Task task);
  Future<Result<Task>> updateTask(Task task);
  Future<Result<Task>> moveTask(Task task, String projectId, String sectionId);
  Future<Result<void>> deleteTask(String id);
  Future<Result<void>> closeTask(String id);
  Future<Result<List<Project>>> getProjects();
  Future<Result<Project>> getProject(String id);
  Future<Result<List<Section>>> getSections({String? projectId});
  Future<Result<Section>> getSection(String id);
}
