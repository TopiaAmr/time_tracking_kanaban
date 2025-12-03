import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Kanva'**
  String get appTitle;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get navTeamMembers;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get navHelpSupport;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @taskColumnTodo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get taskColumnTodo;

  /// No description provided for @taskColumnInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get taskColumnInProgress;

  /// No description provided for @taskColumnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskColumnDone;

  /// No description provided for @taskColumnBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get taskColumnBlocked;

  /// Button label to add a new task
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Task count in column
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @filterDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filterDateRange;

  /// No description provided for @filterLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get filterLastWeek;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get filterLastMonth;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get filterAllTime;

  /// No description provided for @filterSpecificDateRange.
  ///
  /// In en, this message translates to:
  /// **'Specific date range'**
  String get filterSpecificDateRange;

  /// No description provided for @filterAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get filterAssignedTo;

  /// No description provided for @filterCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get filterCompany;

  /// No description provided for @filterTaskType.
  ///
  /// In en, this message translates to:
  /// **'Task Type'**
  String get filterTaskType;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchPlaceholder;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get viewBoard;

  /// No description provided for @viewTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get viewTimeline;

  /// No description provided for @viewCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get viewCalendar;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsLightMode;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get settingsColors;

  /// No description provided for @settingsPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get settingsPrimaryColor;

  /// No description provided for @settingsSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get settingsSecondaryColor;

  /// No description provided for @settingsAccentColors.
  ///
  /// In en, this message translates to:
  /// **'Accent Colors'**
  String get settingsAccentColors;

  /// No description provided for @settingsAccentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get settingsAccentBlue;

  /// No description provided for @settingsAccentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get settingsAccentGreen;

  /// No description provided for @settingsAccentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get settingsAccentOrange;

  /// No description provided for @settingsAccentPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get settingsAccentPurple;

  /// No description provided for @settingsAccentRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get settingsAccentRed;

  /// No description provided for @settingsResetColors.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get settingsResetColors;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @taskComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get taskComments;

  /// No description provided for @taskAssignees.
  ///
  /// In en, this message translates to:
  /// **'Assignees'**
  String get taskAssignees;

  /// No description provided for @taskDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get taskDueDate;

  /// No description provided for @taskEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get taskEdit;

  /// No description provided for @taskDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get taskDelete;

  /// No description provided for @taskSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get taskSave;

  /// No description provided for @taskCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get taskCancel;

  /// No description provided for @taskPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get taskPriority;

  /// No description provided for @taskProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get taskProject;

  /// No description provided for @taskDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get taskDuration;

  /// No description provided for @taskLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get taskLabels;

  /// No description provided for @taskDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get taskDates;

  /// No description provided for @taskCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get taskCreatedAt;

  /// No description provided for @taskUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get taskUpdatedAt;

  /// No description provided for @taskCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompletedAt;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @taskActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get taskActive;

  /// No description provided for @taskPriorityP1.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get taskPriorityP1;

  /// No description provided for @taskPriorityP2.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityP2;

  /// No description provided for @taskPriorityP3.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get taskPriorityP3;

  /// No description provided for @taskPriorityP4.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityP4;

  /// No description provided for @taskMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get taskMinutes;

  /// No description provided for @taskNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskNoDueDate;

  /// No description provided for @taskUpdated.
  ///
  /// In en, this message translates to:
  /// **'Task updated successfully'**
  String get taskUpdated;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted successfully'**
  String get taskDeleted;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get errorUnknown;

  /// No description provided for @emptyTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get emptyTasks;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStop;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timerResume;

  /// No description provided for @timerHistory.
  ///
  /// In en, this message translates to:
  /// **'Timer History'**
  String get timerHistory;

  /// No description provided for @commentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add comment'**
  String get commentAdd;

  /// No description provided for @commentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commentEdit;

  /// No description provided for @commentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commentDelete;

  /// No description provided for @commentReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentReply;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task?'**
  String get confirmDeleteTask;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @historyCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get historyCompletedTasks;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @projectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projectsTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
