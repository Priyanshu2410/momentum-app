enum TaskLabel {
  work('work', 'Work'),
  personal('personal', 'Personal'),
  health('health', 'Health'),
  finance('finance', 'Finance'),
  other('other', 'Other');

  const TaskLabel(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TaskLabel fromDb(String value) => values.firstWhere(
        (l) => l.dbValue == value,
        orElse: () => TaskLabel.other,
      );
}
