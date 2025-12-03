// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Kanva';

  @override
  String get navOverview => 'Vue d\'ensemble';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProjects => 'Projets';

  @override
  String get navTasks => 'Tâches';

  @override
  String get navTeamMembers => 'Membres de l\'équipe';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navHelpSupport => 'Aide & Support';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get taskColumnTodo => 'À faire';

  @override
  String get taskColumnInProgress => 'En cours';

  @override
  String get taskColumnDone => 'Terminé';

  @override
  String get taskColumnBlocked => 'Bloqué';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
      zero: 'Aucune tâche',
    );
    return '$_temp0';
  }

  @override
  String get filterDateRange => 'Plage de dates';

  @override
  String get filterLastWeek => 'Semaine dernière';

  @override
  String get filterLastMonth => 'Mois dernier';

  @override
  String get filterAllTime => 'Tout le temps';

  @override
  String get filterSpecificDateRange => 'Plage de dates spécifique';

  @override
  String get filterAssignedTo => 'Assigné à';

  @override
  String get filterCompany => 'Entreprise';

  @override
  String get filterTaskType => 'Type de tâche';

  @override
  String get clearFilter => 'Effacer le filtre';

  @override
  String get searchPlaceholder => 'Rechercher';

  @override
  String get viewList => 'Liste';

  @override
  String get viewBoard => 'Tableau';

  @override
  String get viewTimeline => 'Chronologie';

  @override
  String get viewCalendar => 'Calendrier';

  @override
  String get filters => 'Filtres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLightMode => 'Mode clair';

  @override
  String get settingsDarkMode => 'Mode sombre';

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
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskComments => 'Commentaires';

  @override
  String get taskAssignees => 'Assignés';

  @override
  String get taskDueDate => 'Date d\'échéance';

  @override
  String get taskEdit => 'Modifier la tâche';

  @override
  String get taskDelete => 'Supprimer la tâche';

  @override
  String get taskSave => 'Enregistrer';

  @override
  String get taskCancel => 'Annuler';

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
  String get errorNetwork => 'Une erreur réseau s\'est produite';

  @override
  String get errorUnknown => 'Une erreur inconnue s\'est produite';

  @override
  String get emptyTasks => 'Aucune tâche trouvée';

  @override
  String get loading => 'Chargement...';

  @override
  String get timerStart => 'Démarrer';

  @override
  String get timerStop => 'Arrêter';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Reprendre';

  @override
  String get timerHistory => 'Historique du minuteur';

  @override
  String get commentAdd => 'Ajouter un commentaire';

  @override
  String get commentEdit => 'Modifier';

  @override
  String get commentDelete => 'Supprimer';

  @override
  String get commentReply => 'Répondre';

  @override
  String get confirmDelete => 'Supprimer?';

  @override
  String get confirmDeleteTask =>
      'Êtes-vous sûr de vouloir supprimer cette tâche?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get ok => 'OK';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get historyCompletedTasks => 'Tâches terminées';

  @override
  String get overviewTitle => 'Vue d\'ensemble';

  @override
  String get projectsTitle => 'Projets';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get refresh => 'Actualiser';
}
