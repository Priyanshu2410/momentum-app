/// User-facing copy. Notification bodies use the design's curly quotes.
class AppStrings {
  const AppStrings._();

  static const appName = 'Momentum';

  // Pushed notification copy lives in `notification_copy.dart` — it carries a
  // quote and HTML styling that plain strings cannot.

  // Notification-log entries
  static String startedLog(String title) => '“$title” just started — tap to open';
  static String overdueLog(String title) => '“$title” is overdue';

  // Toasts
  static String startedToast(String title) => '“$title” just started';
  static const snoozed = 'Snoozed to tomorrow';
  static String taskAdded(String status) => 'Task added to $status';
  static const taskUpdated = 'Task updated';
  static const taskDeleted = 'Task deleted';

  // Empty states
  static const nothingHere = 'Nothing here yet.';
  static const nothingHereHint = 'Clear filters or add a task.';
  static const allClear = 'All clear.';
  static const allClearHint = 'Notifications will appear here when tasks activate.';

  // Validation
  static const titleRequired = 'Give the task a title.';
  static const startBeforeDue = 'Start has to come before due.';

  // Quick add
  static const newTask = 'New task';
  static const titleHint = 'What needs to happen?';
  static const descriptionHint = 'Add details... (optional)';
  static const addTask = 'Add task';

  // Scheduling — always says which column the task ends up in.
  static const whenStart = 'When does it start?';
  static const whenDue = 'When is it due?';
  static const landsInProgress = 'Starts now — goes straight to In Progress.';
  static String landsScheduled(String when) => 'Waits in Scheduled until $when.';
  static const noDueDate = 'No deadline';

  // Detail
  static const addDescription = 'Add description...';
  static const deleteTask = 'Delete task';
  static const saveChanges = 'Save changes';

  // Settings
  static const settings = 'Settings';
  static const autoPromote = 'Auto-promote scheduled tasks';
  static const pushNotifications = 'Push notifications';
  static const checkForUpdates = 'Check for updates';
  static const checking = 'Checking...';
  static const upToDate = 'You are on the latest version';
  static const updatesUnavailable = 'Updates only work on release builds';

  // Updates
  static const updateTitle = 'New version available';
  static String updateVersions(String from, String to) => '$from  →  $to';
  static const updateDownload = 'Download';
  static const updateLater = 'Later';
}
