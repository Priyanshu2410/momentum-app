enum TaskPriority {
  high('high', 'High'),
  medium('medium', 'Medium'),
  low('low', 'Low');

  const TaskPriority(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static TaskPriority fromDb(String value) => values.firstWhere(
        (p) => p.dbValue == value,
        orElse: () => TaskPriority.medium,
      );
}
