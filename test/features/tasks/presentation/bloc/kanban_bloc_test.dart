import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/close_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/move_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_event.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_state.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_active_timer_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import 'kanban_bloc_test.mocks.dart';

@GenerateMocks([
  GetTasksUseCase,
  MoveTaskUseCase,
  AddTaskUseCase,
  UpdateTaskUseCase,
  CloseTaskUseCase,
  GetActiveTimerUseCase,
])
void main() {
  late KanbanBloc kanbanBloc;
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockMoveTaskUseCase mockMoveTaskUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockCloseTaskUseCase mockCloseTaskUseCase;
  late MockGetActiveTimerUseCase mockGetActiveTimerUseCase;

  final dummyDateTime = DateTime(2024, 1, 1);

  Task createTask({
    required String id,
    required bool checked,
    String? projectId,
    String? sectionId,
  }) {
    return Task(
      userId: 'user1',
      id: id,
      projectId: projectId ?? 'project1',
      sectionId: sectionId ?? 'section1',
      addedByUid: 'user1',
      labels: const [],
      checked: checked,
      isDeleted: false,
      addedAt: dummyDateTime,
      updatedAt: dummyDateTime,
      priority: 1,
      childOrder: 0,
      content: 'Task $id',
      description: '',
      noteCount: 0,
      dayOrder: 0,
      isCollapsed: false,
    );
  }

  setUp(() {
    setupMockDummyValues();
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockMoveTaskUseCase = MockMoveTaskUseCase();
    mockAddTaskUseCase = MockAddTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockCloseTaskUseCase = MockCloseTaskUseCase();
    mockGetActiveTimerUseCase = MockGetActiveTimerUseCase();

    kanbanBloc = KanbanBloc(
      mockGetTasksUseCase,
      mockMoveTaskUseCase,
      mockAddTaskUseCase,
      mockUpdateTaskUseCase,
      mockCloseTaskUseCase,
      mockGetActiveTimerUseCase,
    );
  });

  tearDown(() {
    kanbanBloc.close();
  });

  group('KanbanBloc', () {
    test('initial state is KanbanInitial', () {
      expect(kanbanBloc.state, const KanbanInitial());
    });

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanLoaded] when LoadKanbanTasks succeeds',
      build: () {
        final tasks = [
          createTask(id: '1', checked: false),
          createTask(id: '2', checked: true),
          createTask(id: '3', checked: false),
        ];
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks()),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [
            createTask(id: '1', checked: false),
            createTask(id: '3', checked: false),
          ],
          inProgressTasks: [],
          doneTasks: [
            createTask(id: '2', checked: true),
          ],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'groups tasks correctly with active timer',
      build: () {
        final tasks = [
          createTask(id: '1', checked: false),
          createTask(id: '2', checked: false),
          createTask(id: '3', checked: true),
        ];
        final activeTimer = TimeLog(
          id: 'timer1',
          taskId: '1',
          startTime: dummyDateTime,
          endTime: null,
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(activeTimer),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks()),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [
            createTask(id: '2', checked: false),
          ],
          inProgressTasks: [
            createTask(id: '1', checked: false),
          ],
          doneTasks: [
            createTask(id: '3', checked: true),
          ],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when LoadKanbanTasks fails',
      build: () {
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => const Error<List<Task>>(ServerFailure()),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks()),
      expect: () => [
        const KanbanLoading(),
        KanbanError(ServerFailure()),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanLoaded] when MoveTask succeeds',
      build: () {
        final movedTask = createTask(
          id: '1',
          checked: false,
          projectId: 'project2',
          sectionId: 'section2',
        );
        when(mockMoveTaskUseCase(any)).thenAnswer(
          (_) async => Success(movedTask),
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success([movedTask]),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        MoveTaskEvent(
          task: createTask(id: '1', checked: false),
          projectId: 'project2',
          sectionId: 'section2',
        ),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [
            createTask(
              id: '1',
              checked: false,
              projectId: 'project2',
              sectionId: 'section2',
            ),
          ],
          inProgressTasks: [],
          doneTasks: [],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when MoveTask fails',
      build: () {
        when(mockMoveTaskUseCase(any)).thenAnswer(
          (_) async => const Error<Task>(ServerFailure()),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        MoveTaskEvent(
          task: createTask(id: '1', checked: false),
          projectId: 'project2',
          sectionId: 'section2',
        ),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanError(ServerFailure()),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanLoaded] when CreateTask succeeds',
      build: () {
        final newTask = createTask(id: '1', checked: false);
        when(mockAddTaskUseCase(any)).thenAnswer(
          (_) async => Success(newTask),
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success([newTask]),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CreateTask(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [
            createTask(id: '1', checked: false),
          ],
          inProgressTasks: [],
          doneTasks: [],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when CreateTask fails',
      build: () {
        when(mockAddTaskUseCase(any)).thenAnswer(
          (_) async => const Error<Task>(ServerFailure()),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CreateTask(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanError(ServerFailure()),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanLoaded] when UpdateTask succeeds',
      build: () {
        final updatedTask = createTask(id: '1', checked: false);
        when(mockUpdateTaskUseCase(any)).thenAnswer(
          (_) async => Success(updatedTask),
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success([updatedTask]),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        UpdateTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [
            createTask(id: '1', checked: false),
          ],
          inProgressTasks: [],
          doneTasks: [],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when UpdateTask fails',
      build: () {
        when(mockUpdateTaskUseCase(any)).thenAnswer(
          (_) async => const Error<Task>(ServerFailure()),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        UpdateTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanError(ServerFailure()),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanLoaded] when CloseTask succeeds',
      build: () {
        final closedTask = createTask(id: '1', checked: true);
        when(mockCloseTaskUseCase(any)).thenAnswer(
          (_) async => Success(closedTask),
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success([closedTask]),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CloseTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanLoaded(
          toDoTasks: [],
          inProgressTasks: [],
          doneTasks: [
            createTask(id: '1', checked: true),
          ],
        ),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when CloseTask fails',
      build: () {
        when(mockCloseTaskUseCase(any)).thenAnswer(
          (_) async => const Error<Task>(ServerFailure()),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CloseTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        KanbanError(ServerFailure()),
      ],
    );
  });
}

