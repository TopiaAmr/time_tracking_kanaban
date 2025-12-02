// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'core/database/app_database.dart' as _i111;
import 'core/database/database_module.dart' as _i356;
import 'core/network/connectivity_service.dart' as _i76;
import 'core/network/network_module.dart' as _i550;
import 'features/tasks/data/datasources/comments_local_datasource.dart'
    as _i939;
import 'features/tasks/data/datasources/tasks_local_datasource.dart' as _i884;
import 'features/tasks/data/datasources/todoist_api.dart' as _i381;
import 'features/tasks/data/repositories/comments_repository_impl.dart'
    as _i896;
import 'features/tasks/data/repositories/tasks_repository_impl.dart' as _i411;
import 'features/tasks/domain/repository/comments_repository.dart' as _i861;
import 'features/tasks/domain/repository/tasks_repository.dart' as _i81;
import 'features/tasks/domain/usecases/add_comment_usecase.dart' as _i968;
import 'features/tasks/domain/usecases/add_task_usecase.dart' as _i923;
import 'features/tasks/domain/usecases/close_task_usecase.dart' as _i460;
import 'features/tasks/domain/usecases/delete_comment_usecase.dart' as _i146;
import 'features/tasks/domain/usecases/get_project_usecase.dart' as _i555;
import 'features/tasks/domain/usecases/get_projects_usecase.dart' as _i91;
import 'features/tasks/domain/usecases/get_section_usecase.dart' as _i220;
import 'features/tasks/domain/usecases/get_sections_usecase.dart' as _i362;
import 'features/tasks/domain/usecases/get_task_comments_usecase.dart' as _i160;
import 'features/tasks/domain/usecases/get_task_usecase.dart' as _i264;
import 'features/tasks/domain/usecases/get_tasks_usecase.dart' as _i951;
import 'features/tasks/domain/usecases/move_task_usecase.dart' as _i584;
import 'features/tasks/domain/usecases/update_comment_usecase.dart' as _i137;
import 'features/tasks/domain/usecases/update_task_usecase.dart' as _i878;
import 'features/timer/data/datasources/timer_local_datasource.dart' as _i93;
import 'features/timer/data/repositories/timer_repository_impl.dart' as _i310;
import 'features/timer/domain/repository/timer_repository.dart' as _i79;
import 'features/timer/domain/usecases/get_active_timer_usecase.dart' as _i540;
import 'features/timer/domain/usecases/get_completed_tasks_history_usecase.dart'
    as _i1062;
import 'features/timer/domain/usecases/get_task_time_logs_usecase.dart'
    as _i219;
import 'features/timer/domain/usecases/get_task_timer_summary_usecase.dart'
    as _i920;
import 'features/timer/domain/usecases/pause_timer_usecase.dart' as _i185;
import 'features/timer/domain/usecases/resume_timer_usecase.dart' as _i970;
import 'features/timer/domain/usecases/start_timer_usecase.dart' as _i647;
import 'features/timer/domain/usecases/stop_timer_usecase.dart' as _i640;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i111.AppDatabase>(() => databaseModule.appDatabase);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i381.TodoistApi>(() => networkModule.todoistApi);
    gh.lazySingleton<_i895.Connectivity>(() => networkModule.connectivity);
    gh.factory<_i939.CommentsLocalDataSource>(
      () => _i939.CommentsLocalDataSource(gh<_i111.AppDatabase>()),
    );
    gh.factory<_i884.TasksLocalDataSource>(
      () => _i884.TasksLocalDataSource(gh<_i111.AppDatabase>()),
    );
    gh.factory<_i93.TimerLocalDataSource>(
      () => _i93.TimerLocalDataSource(gh<_i111.AppDatabase>()),
    );
    gh.factory<_i79.TimerRepository>(
      () => _i310.TimerRepositoryImpl(gh<_i93.TimerLocalDataSource>()),
    );
    gh.lazySingleton<_i76.ConnectivityService>(
      () => _i76.ConnectivityService(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i540.GetActiveTimerUseCase>(
      () => _i540.GetActiveTimerUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i1062.GetCompletedTasksHistoryUseCase>(
      () => _i1062.GetCompletedTasksHistoryUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i219.GetTaskTimeLogsUseCase>(
      () => _i219.GetTaskTimeLogsUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i920.GetTaskTimerSummaryUseCase>(
      () => _i920.GetTaskTimerSummaryUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i185.PauseTimerUseCase>(
      () => _i185.PauseTimerUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i970.ResumeTimerUseCase>(
      () => _i970.ResumeTimerUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i647.StartTimerUseCase>(
      () => _i647.StartTimerUseCase(gh<_i79.TimerRepository>()),
    );
    gh.lazySingleton<_i640.StopTimerUseCase>(
      () => _i640.StopTimerUseCase(gh<_i79.TimerRepository>()),
    );
    gh.factory<_i81.TasksRepository>(
      () => _i411.TasksRepositoryImpl(
        gh<_i381.TodoistApi>(),
        gh<_i884.TasksLocalDataSource>(),
        gh<_i76.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i923.AddTask>(
      () => _i923.AddTask(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i460.CloseTask>(
      () => _i460.CloseTask(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i555.GetProject>(
      () => _i555.GetProject(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i91.GetProjects>(
      () => _i91.GetProjects(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i220.GetSection>(
      () => _i220.GetSection(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i362.GetSections>(
      () => _i362.GetSections(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i264.GetTask>(
      () => _i264.GetTask(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i951.GetTasks>(
      () => _i951.GetTasks(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i584.MoveTask>(
      () => _i584.MoveTask(gh<_i81.TasksRepository>()),
    );
    gh.lazySingleton<_i878.UpdateTask>(
      () => _i878.UpdateTask(gh<_i81.TasksRepository>()),
    );
    gh.factory<_i861.CommentsRepository>(
      () => _i896.CommentsRepositoryImpl(
        gh<_i381.TodoistApi>(),
        gh<_i939.CommentsLocalDataSource>(),
        gh<_i76.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i968.AddComment>(
      () => _i968.AddComment(gh<_i861.CommentsRepository>()),
    );
    gh.lazySingleton<_i146.DeleteComment>(
      () => _i146.DeleteComment(gh<_i861.CommentsRepository>()),
    );
    gh.lazySingleton<_i160.GetTaskComments>(
      () => _i160.GetTaskComments(gh<_i861.CommentsRepository>()),
    );
    gh.lazySingleton<_i137.UpdateComment>(
      () => _i137.UpdateComment(gh<_i861.CommentsRepository>()),
    );
    return this;
  }
}

class _$DatabaseModule extends _i356.DatabaseModule {}

class _$NetworkModule extends _i550.NetworkModule {}
