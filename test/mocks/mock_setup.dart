import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

// Provide dummy values for Result<T> sealed class
// This function should be called before using mocks
void setupMockDummyValues() {
  final dummyDateTime = DateTime(2024, 1, 1);

  provideDummy<Result<Task>>(
    Success(
      Task(
        userId: '',
        id: '',
        projectId: '',
        sectionId: '',
        addedByUid: '',
        labels: const [],
        checked: false,
        isDeleted: false,
        addedAt: dummyDateTime,
        updatedAt: dummyDateTime,
        priority: 0,
        childOrder: 0,
        content: '',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      ),
    ),
  );

  provideDummy<Result<List<Task>>>(const Success(<Task>[]));

  provideDummy<Result<Project>>(
    Success(
      Project(
        id: '',
        canAssignTasks: false,
        childOrder: 0,
        color: '',
        creatorUid: '',
        createdAt: dummyDateTime,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: '',
        updatedAt: dummyDateTime,
        viewStyle: '',
        defaultOrder: 0,
        description: '',
        publicAccess: false,
        publicKey: '',
        access: const ProjectAccess(visibility: '', configuration: {}),
        role: '',
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      ),
    ),
  );

  provideDummy<Result<List<Project>>>(const Success(<Project>[]));

  provideDummy<Result<Section>>(
    Success(
      Section(
        id: '',
        userId: '',
        projectId: '',
        addedAt: dummyDateTime,
        updatedAt: dummyDateTime,
        name: '',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      ),
    ),
  );

  provideDummy<Result<List<Section>>>(const Success(<Section>[]));

  // Timer entities
  provideDummy<Result<TimeLog>>(
    Success(
      TimeLog(id: '', taskId: '', startTime: dummyDateTime, endTime: null),
    ),
  );

  provideDummy<Result<TimeLog?>>(Success<TimeLog?>(null));

  provideDummy<Result<List<TimeLog>>>(const Success(<TimeLog>[]));

  provideDummy<Result<TaskTimerSummary>>(
    Success(
      const TaskTimerSummary(
        taskId: '',
        taskTitle: 'Test Task',
        totalTrackedSeconds: 0,
        hasActiveTimer: false,
      ),
    ),
  );

  provideDummy<Result<List<TaskTimerSummary>>>(
    const Success(<TaskTimerSummary>[]),
  );

  // Comment entities
  provideDummy<Result<Comment>>(
    Success(
      Comment(
        id: '',
        taskId: '',
        content: '',
        createdAt: dummyDateTime,
        updatedAt: dummyDateTime,
        authorId: '',
        authorName: null,
        isSynced: true,
      ),
    ),
  );

  provideDummy<Result<List<Comment>>>(const Success(<Comment>[]));

  // For Result<void>, we use null cast to dynamic since void can't have a value
  provideDummy<Result<void>>(const Success<void>(null));
}
