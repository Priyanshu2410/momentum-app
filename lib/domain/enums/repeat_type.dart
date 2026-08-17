enum RepeatType {
  none('none', 'None', ''),
  daily('daily', 'Daily', 'at start time'),
  weekly('weekly', 'Weekly', ''),
  monthly('monthly', 'Monthly', 'same date'),
  custom('custom', 'Custom', '');

  const RepeatType(this.dbValue, this.label, this.hint);

  final String dbValue;
  final String label;

  /// Trailing muted text on the repeat picker rows.
  final String hint;

  bool get repeats => this != RepeatType.none;

  static RepeatType fromDb(String value) => values.firstWhere(
        (r) => r.dbValue == value,
        orElse: () => RepeatType.none,
      );
}
