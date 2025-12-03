import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/close_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_sections_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart'
    show GetTasksParams, GetTasksUseCase;
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/move_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_event.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_state.dart';

import '../../../../mocks/mock_setup.dart';
import 'kanban_bloc_test.mocks.dart';

@GenerateMocks([
  GetTasksUseCase,
  MoveTaskUseCase,
  AddTaskUseCase,
  UpdateTaskUseCase,
  CloseTaskUseCase,
  DeleteTaskUseCase,
  GetSections,
  TimerBloc,
])
void main() {
  late KanbanBloc kanbanBloc;
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockMoveTaskUseCase mockMoveTaskUseCase;
  late MockAddTaskUseCase mockAddTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockCloseTaskUseCase mockCloseTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockGetSections mockGetSections;
  late MockTimerBloc mockTimerBloc;

  final dummyDateTime = DateTime(2024, 1, 1);

  Section createSection({
    required String id,
    required String name,
    int sectionOrder = 0,
  }) {
    return Section(
      id: id,
      userId: 'user1',
      projectId: 'project1',
      addedAt: dummyDateTime,
      updatedAt: dummyDateTime,
      name: name,
      sectionOrder: sectionOrder,
      isArchived: false,
      isDeleted: false,
      isCollapsed: false,
    );
  }

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
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockGetSections = MockGetSections();
    mockTimerBloc = MockTimerBloc();

    kanbanBloc = KanbanBloc(
      mockGetTasksUseCase,
      mockMoveTaskUseCase,
      mockAddTaskUseCase,
      mockUpdateTaskUseCase,
      mockCloseTaskUseCase,
      mockDeleteTaskUseCase,
      mockGetSections,
      mockTimerBloc,
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
        final section1 = createSection(id: 'section1', name: 'Section 1');
        final tasks = [
          createTask(id: '1', checked: false, sectionId: 'section1'),
          createTask(id: '2', checked: false, sectionId: 'section1'),
          createTask(id: '3', checked: false, sectionId: ''),
        ];
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section1]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks()),
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksBySection['section1']?.length == 2 &&
              state.tasksWithoutSection.length == 1 &&
              state.sections.length == 1;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'groups tasks correctly by sections',
      build: () {
        final section1 = createSection(id: 'section1', name: 'Section 1');
        final section2 = createSection(id: 'section2', name: 'Section 2');
        final tasks = [
          createTask(id: '1', checked: false, sectionId: 'section1'),
          createTask(id: '2', checked: false, sectionId: 'section2'),
          createTask(id: '3', checked: false, sectionId: ''),
        ];
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section1, section2]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks()),
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksBySection['section1']?.length == 1 &&
              state.tasksBySection['section2']?.length == 1 &&
              state.tasksWithoutSection.length == 1 &&
              state.sections.length == 2;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanLoading, KanbanError] when LoadKanbanTasks fails',
      build: () {
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => const Error<List<Task>>(ServerFailure()),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => const Success<List<Section>>([]),
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
        final section2 = createSection(id: 'section2', name: 'Section 2');
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
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section2]),
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
        predicate<KanbanLoaded>((state) {
          return state.tasksBySection['section2']?.length == 1 &&
              state.tasksWithoutSection.isEmpty &&
              state.sections.length == 1;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanError] when MoveTask fails',
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
        when(mockGetSections(any)).thenAnswer(
          (_) async => const Success<List<Section>>([]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CreateTask(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksWithoutSection.length == 1 &&
              state.tasksBySection.isEmpty &&
              state.sections.isEmpty;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanError] when CreateTask fails',
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
        when(mockGetSections(any)).thenAnswer(
          (_) async => const Success<List<Section>>([]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        UpdateTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksWithoutSection.length == 1 &&
              state.tasksBySection.isEmpty &&
              state.sections.isEmpty;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanError] when UpdateTask fails',
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
        when(mockGetSections(any)).thenAnswer(
          (_) async => const Success<List<Section>>([]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CloseTaskEvent(createTask(id: '1', checked: false)),
      ),
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksWithoutSection.length == 1 &&
              state.tasksBySection.isEmpty &&
              state.sections.isEmpty;
        }),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'emits [KanbanError] when CloseTask fails',
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
        KanbanError(ServerFailure()),
      ],
    );

    blocTest<KanbanBloc, KanbanState>(
      'dispatches StopTimerForTask to TimerBloc when closing a task',
      build: () {
        final closedTask = createTask(id: 'task-123', checked: true);
        when(mockCloseTaskUseCase(any)).thenAnswer(
          (_) async => Success(closedTask),
        );
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success([closedTask]),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => const Success<List<Section>>([]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(
        CloseTaskEvent(createTask(id: 'task-123', checked: false)),
      ),
      verify: (_) {
        // Verify that StopTimerForTask was dispatched to TimerBloc
        verify(mockTimerBloc.add(any)).called(1);
      },
    );

    blocTest<KanbanBloc, KanbanState>(
      'LoadKanbanTasks with forceRefresh: false passes forceRefresh: false to use case',
      build: () {
        final section1 = createSection(id: 'section1', name: 'Section 1');
        final tasks = [createTask(id: '1', checked: false, sectionId: 'section1')];
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section1]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks(forceRefresh: false)),
      verify: (_) {
        final captured = verify(mockGetTasksUseCase(captureAny)).captured;
        expect(captured.length, 1);
        final params = captured.first as GetTasksParams;
        expect(params.forceRefresh, false);
      },
    );

    blocTest<KanbanBloc, KanbanState>(
      'LoadKanbanTasks with forceRefresh: true passes forceRefresh: true to use case',
      build: () {
        final section1 = createSection(id: 'section1', name: 'Section 1');
        final tasks = [createTask(id: '1', checked: false, sectionId: 'section1')];
        when(mockGetTasksUseCase(any)).thenAnswer(
          (_) async => Success(tasks),
        );
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section1]),
        );
        return kanbanBloc;
      },
      act: (bloc) => bloc.add(const LoadKanbanTasks(forceRefresh: true)),
      verify: (_) {
        final captured = verify(mockGetTasksUseCase(captureAny)).captured;
        expect(captured.length, 1);
        final params = captured.first as GetTasksParams;
        expect(params.forceRefresh, true);
      },
    );

    blocTest<KanbanBloc, KanbanState>(
      'refresh (forceRefresh: true) updates state with fresh data from API',
      build: () {
        final section1 = createSection(id: 'section1', name: 'Section 1');
        final initialTasks = [createTask(id: '1', checked: false, sectionId: 'section1')];
        final refreshedTasks = [
          createTask(id: '1', checked: false, sectionId: 'section1'),
          createTask(id: '2', checked: false, sectionId: 'section1'),
        ];
        
        var callCount = 0;
        when(mockGetTasksUseCase(any)).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Success(initialTasks);
          }
          return Success(refreshedTasks);
        });
        when(mockGetSections(any)).thenAnswer(
          (_) async => Success([section1]),
        );
        return kanbanBloc;
      },
      act: (bloc) async {
        // First load
        bloc.add(const LoadKanbanTasks(forceRefresh: false));
        await Future.delayed(const Duration(milliseconds: 100));
        // Refresh
        bloc.add(const LoadKanbanTasks(forceRefresh: true));
      },
      expect: () => [
        const KanbanLoading(),
        predicate<KanbanLoaded>((state) {
          return state.tasksBySection['section1']?.length == 1;
        }),
        predicate<KanbanLoaded>((state) {
          return state.tasksBySection['section1']?.length == 2;
        }),
      ],
    );
  });
}

