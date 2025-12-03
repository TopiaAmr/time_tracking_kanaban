// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kanva';

  @override
  String get navOverview => 'Genel Bakış';

  @override
  String get navNotifications => 'Bildirimler';

  @override
  String get navProjects => 'Projeler';

  @override
  String get navTasks => 'Görevler';

  @override
  String get navTeamMembers => 'Takım Üyeleri';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navHelpSupport => 'Yardım & Destek';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get taskColumnTodo => 'Yapılacaklar';

  @override
  String get taskColumnInProgress => 'Devam Ediyor';

  @override
  String get taskColumnDone => 'Tamamlandı';

  @override
  String get taskColumnBlocked => 'Engellendi';

  @override
  String get addTask => 'Görev Ekle';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count görev',
      one: '1 görev',
      zero: 'Görev yok',
    );
    return '$_temp0';
  }

  @override
  String get filterDateRange => 'Tarih Aralığı';

  @override
  String get filterLastWeek => 'Geçen hafta';

  @override
  String get filterLastMonth => 'Geçen ay';

  @override
  String get filterAllTime => 'Tüm zamanlar';

  @override
  String get filterSpecificDateRange => 'Belirli tarih aralığı';

  @override
  String get filterAssignedTo => 'Atanan';

  @override
  String get filterCompany => 'Şirket';

  @override
  String get filterTaskType => 'Görev Türü';

  @override
  String get clearFilter => 'Filtreyi Temizle';

  @override
  String get searchPlaceholder => 'Ara';

  @override
  String get viewList => 'Liste';

  @override
  String get viewBoard => 'Pano';

  @override
  String get viewTimeline => 'Zaman Çizelgesi';

  @override
  String get viewCalendar => 'Takvim';

  @override
  String get filters => 'Filtreler';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLightMode => 'Açık Mod';

  @override
  String get settingsDarkMode => 'Koyu Mod';

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
  String get taskTitle => 'Görev Başlığı';

  @override
  String get taskDescription => 'Açıklama';

  @override
  String get taskComments => 'Yorumlar';

  @override
  String get taskAssignees => 'Atananlar';

  @override
  String get taskDueDate => 'Bitiş Tarihi';

  @override
  String get taskEdit => 'Görevi Düzenle';

  @override
  String get taskDelete => 'Görevi Sil';

  @override
  String get taskSave => 'Kaydet';

  @override
  String get taskCancel => 'İptal';

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
  String get errorNetwork => 'Ağ hatası oluştu';

  @override
  String get errorUnknown => 'Bilinmeyen bir hata oluştu';

  @override
  String get emptyTasks => 'Görev bulunamadı';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get timerStart => 'Başlat';

  @override
  String get timerStop => 'Durdur';

  @override
  String get timerPause => 'Duraklat';

  @override
  String get timerResume => 'Devam Et';

  @override
  String get timerHistory => 'Zamanlayıcı Geçmişi';

  @override
  String get commentAdd => 'Yorum ekle';

  @override
  String get commentEdit => 'Düzenle';

  @override
  String get commentDelete => 'Sil';

  @override
  String get commentReply => 'Yanıtla';

  @override
  String get confirmDelete => 'Sil?';

  @override
  String get confirmDeleteTask =>
      'Bu görevi silmek istediğinizden emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get ok => 'Tamam';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get historyCompletedTasks => 'Tamamlanan Görevler';

  @override
  String get overviewTitle => 'Genel Bakış';

  @override
  String get projectsTitle => 'Projeler';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get refresh => 'Yenile';
}
