/// Declaration order is the board / list column order from the design:
/// In Progress -> Overdue -> Scheduled -> Done.
/// `TaskStatus.values` is therefore the render order everywhere — no separate
/// ORDER constant to keep in sync.
enum TaskStatus {
  inProgress('in_progress', 'In Progress'),
  overdue('overdue', 'Overdue'),
  scheduled('scheduled', 'Scheduled'),
  done('done', 'Done');

  const TaskStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  bool get isDone => this == TaskStatus.done;

  /// Unknown values fall back to `scheduled` rather than throwing — a corrupt
  /// row should not take the whole board down.
  static TaskStatus fromDb(String value) => values.firstWhere(
        (s) => s.dbValue == value,
        orElse: () => TaskStatus.scheduled,
      );
}
