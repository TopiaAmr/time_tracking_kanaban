// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kanva';

  @override
  String get navOverview => 'Overview';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProjects => 'Projects';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navTeamMembers => 'Team Members';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHelpSupport => 'Help & Support';

  @override
  String get navSettings => 'Settings';

  @override
  String get taskColumnTodo => 'Todo';

  @override
  String get taskColumnInProgress => 'In Progress';

  @override
  String get taskColumnDone => 'Done';

  @override
  String get taskColumnBlocked => 'Blocked';

  @override
  String get addTask => 'Add Task';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get filterDateRange => 'Date Range';

  @override
  String get filterLastWeek => 'Last week';

  @override
  String get filterLastMonth => 'Last month';

  @override
  String get filterAllTime => 'All time';

  @override
  String get filterSpecificDateRange => 'Specific date range';

  @override
  String get filterAssignedTo => 'Assigned to';

  @override
  String get filterCompany => 'Company';

  @override
  String get filterTaskType => 'Task Type';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get searchPlaceholder => 'Search';

  @override
  String get viewList => 'List';

  @override
  String get viewBoard => 'Board';

  @override
  String get viewTimeline => 'Timeline';

  @override
  String get viewCalendar => 'Calendar';

  @override
  String get filters => 'Filters';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLightMode => 'Light Mode';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsColors => 'Colors';

  @override
  String get settingsPrimaryColor => 'Primary Color';

  @override
  String get settingsSecondaryColor => 'Secondary Color';

  @override
  String get settingsAccentColors => 'Accent Colors';

  @override
  String get settingsAccentBlue => 'Blue';

  @override
  String get settingsAccentGreen => 'Green';

  @override
  String get settingsAccentOrange => 'Orange';

  @override
  String get settingsAccentPurple => 'Purple';

  @override
  String get settingsAccentRed => 'Red';

  @override
  String get settingsResetColors => 'Reset to Default';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskComments => 'Comments';

  @override
  String get taskAssignees => 'Assignees';

  @override
  String get taskDueDate => 'Due Date';

  @override
  String get taskEdit => 'Edit Task';

  @override
  String get taskDelete => 'Delete Task';

  @override
  String get taskSave => 'Save';

  @override
  String get taskCancel => 'Cancel';

  @override
  String get taskPriority => 'Priority';

  @override
  String get taskProject => 'Project';

  @override
  String get taskDuration => 'Duration';

  @override
  String get taskLabels => 'Labels';

  @override
  String get taskDates => 'Dates';

  @override
  String get taskCreatedAt => 'Created';

  @override
  String get taskUpdatedAt => 'Updated';

  @override
  String get taskCompletedAt => 'Completed';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskActive => 'Active';

  @override
  String get taskPriorityP1 => 'Urgent';

  @override
  String get taskPriorityP2 => 'High';

  @override
  String get taskPriorityP3 => 'Normal';

  @override
  String get taskPriorityP4 => 'Low';

  @override
  String get taskMinutes => 'minutes';

  @override
  String get taskNoDueDate => 'No due date';

  @override
  String get taskUpdated => 'Task updated successfully';

  @override
  String get taskDeleted => 'Task deleted successfully';

  @override
  String get errorNetwork => 'Network error occurred';

  @override
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get emptyTasks => 'No tasks found';

  @override
  String get loading => 'Loading...';

  @override
  String get timerStart => 'Start';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerHistory => 'Timer History';

  @override
  String get commentAdd => 'Add comment';

  @override
  String get commentEdit => 'Edit';

  @override
  String get commentDelete => 'Delete';

  @override
  String get commentReply => 'Reply';

  @override
  String get confirmDelete => 'Delete?';

  @override
  String get confirmDeleteTask => 'Are you sure you want to delete this task?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get historyCompletedTasks => 'Completed Tasks';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get refresh => 'Refresh';
}
