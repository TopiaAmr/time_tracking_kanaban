// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kanva';

  @override
  String get navOverview => 'Übersicht';

  @override
  String get navNotifications => 'Benachrichtigungen';

  @override
  String get navProjects => 'Projekte';

  @override
  String get navTasks => 'Aufgaben';

  @override
  String get navTeamMembers => 'Teammitglieder';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navHelpSupport => 'Hilfe & Support';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get taskColumnTodo => 'Zu erledigen';

  @override
  String get taskColumnInProgress => 'In Bearbeitung';

  @override
  String get taskColumnDone => 'Erledigt';

  @override
  String get taskColumnBlocked => 'Blockiert';

  @override
  String get addTask => 'Aufgabe hinzufügen';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
      zero: 'Keine Aufgaben',
    );
    return '$_temp0';
  }

  @override
  String get filterDateRange => 'Datumsbereich';

  @override
  String get filterLastWeek => 'Letzte Woche';

  @override
  String get filterLastMonth => 'Letzter Monat';

  @override
  String get filterAllTime => 'Gesamte Zeit';

  @override
  String get filterSpecificDateRange => 'Bestimmter Datumsbereich';

  @override
  String get filterAssignedTo => 'Zugewiesen an';

  @override
  String get filterCompany => 'Unternehmen';

  @override
  String get filterTaskType => 'Aufgabentyp';

  @override
  String get clearFilter => 'Filter löschen';

  @override
  String get searchPlaceholder => 'Suchen';

  @override
  String get viewList => 'Liste';

  @override
  String get viewBoard => 'Board';

  @override
  String get viewTimeline => 'Zeitleiste';

  @override
  String get viewCalendar => 'Kalender';

  @override
  String get filters => 'Filter';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLightMode => 'Heller Modus';

  @override
  String get settingsDarkMode => 'Dunkler Modus';

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
  String get taskTitle => 'Aufgabentitel';

  @override
  String get taskDescription => 'Beschreibung';

  @override
  String get taskComments => 'Kommentare';

  @override
  String get taskAssignees => 'Zugewiesene';

  @override
  String get taskDueDate => 'Fälligkeitsdatum';

  @override
  String get taskEdit => 'Aufgabe bearbeiten';

  @override
  String get taskDelete => 'Aufgabe löschen';

  @override
  String get taskSave => 'Speichern';

  @override
  String get taskCancel => 'Abbrechen';

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
  String get errorNetwork => 'Netzwerkfehler aufgetreten';

  @override
  String get errorUnknown => 'Ein unbekannter Fehler ist aufgetreten';

  @override
  String get emptyTasks => 'Keine Aufgaben gefunden';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get timerStart => 'Start';

  @override
  String get timerStop => 'Stopp';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Fortsetzen';

  @override
  String get timerHistory => 'Timer-Verlauf';

  @override
  String get commentAdd => 'Kommentar hinzufügen';

  @override
  String get commentEdit => 'Bearbeiten';

  @override
  String get commentDelete => 'Löschen';

  @override
  String get commentReply => 'Antworten';

  @override
  String get confirmDelete => 'Löschen?';

  @override
  String get confirmDeleteTask =>
      'Sind Sie sicher, dass Sie diese Aufgabe löschen möchten?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get ok => 'OK';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get historyCompletedTasks => 'Abgeschlossene Aufgaben';

  @override
  String get overviewTitle => 'Übersicht';

  @override
  String get projectsTitle => 'Projekte';

  @override
  String get notificationsTitle => 'Benachrichtigungen';
}
