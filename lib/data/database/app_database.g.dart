// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 200),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('scheduled'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('personal'));
  static const VerificationMeta _repeatTypeMeta =
      const VerificationMeta('repeatType');
  @override
  late final GeneratedColumn<String> repeatType = GeneratedColumn<String>(
      'repeat_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _repeatConfigMeta =
      const VerificationMeta('repeatConfig');
  @override
  late final GeneratedColumn<String> repeatConfig = GeneratedColumn<String>(
      'repeat_config', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateTimeMeta =
      const VerificationMeta('startDateTime');
  @override
  late final GeneratedColumn<DateTime> startDateTime =
      GeneratedColumn<DateTime>('start_date_time', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateTimeMeta =
      const VerificationMeta('dueDateTime');
  @override
  late final GeneratedColumn<DateTime> dueDateTime = GeneratedColumn<DateTime>(
      'due_date_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startNotificationIdMeta =
      const VerificationMeta('startNotificationId');
  @override
  late final GeneratedColumn<int> startNotificationId = GeneratedColumn<int>(
      'start_notification_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueNotificationIdMeta =
      const VerificationMeta('dueNotificationId');
  @override
  late final GeneratedColumn<int> dueNotificationId = GeneratedColumn<int>(
      'due_notification_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        status,
        priority,
        label,
        repeatType,
        repeatConfig,
        startDateTime,
        dueDateTime,
        createdAt,
        completedAt,
        startNotificationId,
        dueNotificationId,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<TaskRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('repeat_type')) {
      context.handle(
          _repeatTypeMeta,
          repeatType.isAcceptableOrUnknown(
              data['repeat_type']!, _repeatTypeMeta));
    }
    if (data.containsKey('repeat_config')) {
      context.handle(
          _repeatConfigMeta,
          repeatConfig.isAcceptableOrUnknown(
              data['repeat_config']!, _repeatConfigMeta));
    }
    if (data.containsKey('start_date_time')) {
      context.handle(
          _startDateTimeMeta,
          startDateTime.isAcceptableOrUnknown(
              data['start_date_time']!, _startDateTimeMeta));
    } else if (isInserting) {
      context.missing(_startDateTimeMeta);
    }
    if (data.containsKey('due_date_time')) {
      context.handle(
          _dueDateTimeMeta,
          dueDateTime.isAcceptableOrUnknown(
              data['due_date_time']!, _dueDateTimeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('start_notification_id')) {
      context.handle(
          _startNotificationIdMeta,
          startNotificationId.isAcceptableOrUnknown(
              data['start_notification_id']!, _startNotificationIdMeta));
    }
    if (data.containsKey('due_notification_id')) {
      context.handle(
          _dueNotificationIdMeta,
          dueNotificationId.isAcceptableOrUnknown(
              data['due_notification_id']!, _dueNotificationIdMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      repeatType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_type'])!,
      repeatConfig: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_config']),
      startDateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}start_date_time'])!,
      dueDateTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date_time']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      startNotificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}start_notification_id']),
      dueNotificationId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}due_notification_id']),
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final String title;
  final String? description;

  /// 'in_progress' | 'overdue' | 'scheduled' | 'done'
  final String status;

  /// 'high' | 'medium' | 'low'
  final String priority;

  /// 'work' | 'personal' | 'health' | 'finance' | 'other'
  final String label;

  /// 'none' | 'daily' | 'weekly' | 'monthly' | 'custom'
  final String repeatType;

  /// JSON, e.g. {"interval": 2, "unit": "weeks"} or {"days": [1, 3]}
  final String? repeatConfig;
  final DateTime startDateTime;
  final DateTime? dueDateTime;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Mirrors of `Task.startNotificationId` / `dueNotificationId`. The ids are
  /// derived from the row id, so these are written for inspectability rather
  /// than read back at cancel time.
  final int? startNotificationId;
  final int? dueNotificationId;
  final bool isDeleted;
  const TaskRow(
      {required this.id,
      required this.title,
      this.description,
      required this.status,
      required this.priority,
      required this.label,
      required this.repeatType,
      this.repeatConfig,
      required this.startDateTime,
      this.dueDateTime,
      required this.createdAt,
      this.completedAt,
      this.startNotificationId,
      this.dueNotificationId,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['label'] = Variable<String>(label);
    map['repeat_type'] = Variable<String>(repeatType);
    if (!nullToAbsent || repeatConfig != null) {
      map['repeat_config'] = Variable<String>(repeatConfig);
    }
    map['start_date_time'] = Variable<DateTime>(startDateTime);
    if (!nullToAbsent || dueDateTime != null) {
      map['due_date_time'] = Variable<DateTime>(dueDateTime);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || startNotificationId != null) {
      map['start_notification_id'] = Variable<int>(startNotificationId);
    }
    if (!nullToAbsent || dueNotificationId != null) {
      map['due_notification_id'] = Variable<int>(dueNotificationId);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      priority: Value(priority),
      label: Value(label),
      repeatType: Value(repeatType),
      repeatConfig: repeatConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatConfig),
      startDateTime: Value(startDateTime),
      dueDateTime: dueDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDateTime),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      startNotificationId: startNotificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(startNotificationId),
      dueNotificationId: dueNotificationId == null && nullToAbsent
          ? const Value.absent()
          : Value(dueNotificationId),
      isDeleted: Value(isDeleted),
    );
  }

  factory TaskRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      label: serializer.fromJson<String>(json['label']),
      repeatType: serializer.fromJson<String>(json['repeatType']),
      repeatConfig: serializer.fromJson<String?>(json['repeatConfig']),
      startDateTime: serializer.fromJson<DateTime>(json['startDateTime']),
      dueDateTime: serializer.fromJson<DateTime?>(json['dueDateTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      startNotificationId:
          serializer.fromJson<int?>(json['startNotificationId']),
      dueNotificationId: serializer.fromJson<int?>(json['dueNotificationId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'label': serializer.toJson<String>(label),
      'repeatType': serializer.toJson<String>(repeatType),
      'repeatConfig': serializer.toJson<String?>(repeatConfig),
      'startDateTime': serializer.toJson<DateTime>(startDateTime),
      'dueDateTime': serializer.toJson<DateTime?>(dueDateTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'startNotificationId': serializer.toJson<int?>(startNotificationId),
      'dueNotificationId': serializer.toJson<int?>(dueNotificationId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  TaskRow copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          String? status,
          String? priority,
          String? label,
          String? repeatType,
          Value<String?> repeatConfig = const Value.absent(),
          DateTime? startDateTime,
          Value<DateTime?> dueDateTime = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          Value<int?> startNotificationId = const Value.absent(),
          Value<int?> dueNotificationId = const Value.absent(),
          bool? isDeleted}) =>
      TaskRow(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        label: label ?? this.label,
        repeatType: repeatType ?? this.repeatType,
        repeatConfig:
            repeatConfig.present ? repeatConfig.value : this.repeatConfig,
        startDateTime: startDateTime ?? this.startDateTime,
        dueDateTime: dueDateTime.present ? dueDateTime.value : this.dueDateTime,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        startNotificationId: startNotificationId.present
            ? startNotificationId.value
            : this.startNotificationId,
        dueNotificationId: dueNotificationId.present
            ? dueNotificationId.value
            : this.dueNotificationId,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      label: data.label.present ? data.label.value : this.label,
      repeatType:
          data.repeatType.present ? data.repeatType.value : this.repeatType,
      repeatConfig: data.repeatConfig.present
          ? data.repeatConfig.value
          : this.repeatConfig,
      startDateTime: data.startDateTime.present
          ? data.startDateTime.value
          : this.startDateTime,
      dueDateTime:
          data.dueDateTime.present ? data.dueDateTime.value : this.dueDateTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      startNotificationId: data.startNotificationId.present
          ? data.startNotificationId.value
          : this.startNotificationId,
      dueNotificationId: data.dueNotificationId.present
          ? data.dueNotificationId.value
          : this.dueNotificationId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('label: $label, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatConfig: $repeatConfig, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('dueDateTime: $dueDateTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('startNotificationId: $startNotificationId, ')
          ..write('dueNotificationId: $dueNotificationId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      status,
      priority,
      label,
      repeatType,
      repeatConfig,
      startDateTime,
      dueDateTime,
      createdAt,
      completedAt,
      startNotificationId,
      dueNotificationId,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.label == this.label &&
          other.repeatType == this.repeatType &&
          other.repeatConfig == this.repeatConfig &&
          other.startDateTime == this.startDateTime &&
          other.dueDateTime == this.dueDateTime &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.startNotificationId == this.startNotificationId &&
          other.dueNotificationId == this.dueNotificationId &&
          other.isDeleted == this.isDeleted);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<String> priority;
  final Value<String> label;
  final Value<String> repeatType;
  final Value<String?> repeatConfig;
  final Value<DateTime> startDateTime;
  final Value<DateTime?> dueDateTime;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int?> startNotificationId;
  final Value<int?> dueNotificationId;
  final Value<bool> isDeleted;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.label = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.repeatConfig = const Value.absent(),
    this.startDateTime = const Value.absent(),
    this.dueDateTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.startNotificationId = const Value.absent(),
    this.dueNotificationId = const Value.absent(),
    this.isDeleted = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.label = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.repeatConfig = const Value.absent(),
    required DateTime startDateTime,
    this.dueDateTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.startNotificationId = const Value.absent(),
    this.dueNotificationId = const Value.absent(),
    this.isDeleted = const Value.absent(),
  })  : title = Value(title),
        startDateTime = Value(startDateTime);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? label,
    Expression<String>? repeatType,
    Expression<String>? repeatConfig,
    Expression<DateTime>? startDateTime,
    Expression<DateTime>? dueDateTime,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? startNotificationId,
    Expression<int>? dueNotificationId,
    Expression<bool>? isDeleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (label != null) 'label': label,
      if (repeatType != null) 'repeat_type': repeatType,
      if (repeatConfig != null) 'repeat_config': repeatConfig,
      if (startDateTime != null) 'start_date_time': startDateTime,
      if (dueDateTime != null) 'due_date_time': dueDateTime,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (startNotificationId != null)
        'start_notification_id': startNotificationId,
      if (dueNotificationId != null) 'due_notification_id': dueNotificationId,
      if (isDeleted != null) 'is_deleted': isDeleted,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? status,
      Value<String>? priority,
      Value<String>? label,
      Value<String>? repeatType,
      Value<String?>? repeatConfig,
      Value<DateTime>? startDateTime,
      Value<DateTime?>? dueDateTime,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int?>? startNotificationId,
      Value<int?>? dueNotificationId,
      Value<bool>? isDeleted}) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      label: label ?? this.label,
      repeatType: repeatType ?? this.repeatType,
      repeatConfig: repeatConfig ?? this.repeatConfig,
      startDateTime: startDateTime ?? this.startDateTime,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      startNotificationId: startNotificationId ?? this.startNotificationId,
      dueNotificationId: dueNotificationId ?? this.dueNotificationId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<String>(repeatType.value);
    }
    if (repeatConfig.present) {
      map['repeat_config'] = Variable<String>(repeatConfig.value);
    }
    if (startDateTime.present) {
      map['start_date_time'] = Variable<DateTime>(startDateTime.value);
    }
    if (dueDateTime.present) {
      map['due_date_time'] = Variable<DateTime>(dueDateTime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (startNotificationId.present) {
      map['start_notification_id'] = Variable<int>(startNotificationId.value);
    }
    if (dueNotificationId.present) {
      map['due_notification_id'] = Variable<int>(dueNotificationId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('label: $label, ')
          ..write('repeatType: $repeatType, ')
          ..write('repeatConfig: $repeatConfig, ')
          ..write('startDateTime: $startDateTime, ')
          ..write('dueDateTime: $dueDateTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('startNotificationId: $startNotificationId, ')
          ..write('dueNotificationId: $dueNotificationId, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogsTable extends NotificationLogs
    with TableInfo<$NotificationLogsTable, NotificationLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
      'task_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, taskId, message, kind, createdAt, isRead];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_logs';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta,
          taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
    );
  }

  @override
  $NotificationLogsTable createAlias(String alias) {
    return $NotificationLogsTable(attachedDatabase, alias);
  }
}

class NotificationLogRow extends DataClass
    implements Insertable<NotificationLogRow> {
  final int id;
  final int taskId;

  /// Rendered message, already containing the task title.
  /// Not named `text` — that would shadow `Table.text()`, the column builder.
  final String message;

  /// 'started' | 'due_soon' | 'overdue'
  final String kind;
  final DateTime createdAt;
  final bool isRead;
  const NotificationLogRow(
      {required this.id,
      required this.taskId,
      required this.message,
      required this.kind,
      required this.createdAt,
      required this.isRead});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['message'] = Variable<String>(message);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  NotificationLogsCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      message: Value(message),
      kind: Value(kind),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
    );
  }

  factory NotificationLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogRow(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      message: serializer.fromJson<String>(json['message']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'message': serializer.toJson<String>(message),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  NotificationLogRow copyWith(
          {int? id,
          int? taskId,
          String? message,
          String? kind,
          DateTime? createdAt,
          bool? isRead}) =>
      NotificationLogRow(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        message: message ?? this.message,
        kind: kind ?? this.kind,
        createdAt: createdAt ?? this.createdAt,
        isRead: isRead ?? this.isRead,
      );
  NotificationLogRow copyWithCompanion(NotificationLogsCompanion data) {
    return NotificationLogRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      message: data.message.present ? data.message.value : this.message,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('message: $message, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, message, kind, createdAt, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.message == this.message &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead);
}

class NotificationLogsCompanion extends UpdateCompanion<NotificationLogRow> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> message;
  final Value<String> kind;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  const NotificationLogsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.message = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
  });
  NotificationLogsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String message,
    required String kind,
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
  })  : taskId = Value(taskId),
        message = Value(message),
        kind = Value(kind);
  static Insertable<NotificationLogRow> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? message,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (message != null) 'message': message,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
    });
  }

  NotificationLogsCompanion copyWith(
      {Value<int>? id,
      Value<int>? taskId,
      Value<String>? message,
      Value<String>? kind,
      Value<DateTime>? createdAt,
      Value<bool>? isRead}) {
    return NotificationLogsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      message: message ?? this.message,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('message: $message, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $NotificationLogsTable notificationLogs =
      $NotificationLogsTable(this);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  late final NotificationsDao notificationsDao =
      NotificationsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [tasks, notificationLogs];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  Value<String> status,
  Value<String> priority,
  Value<String> label,
  Value<String> repeatType,
  Value<String?> repeatConfig,
  required DateTime startDateTime,
  Value<DateTime?> dueDateTime,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> startNotificationId,
  Value<int?> dueNotificationId,
  Value<bool> isDeleted,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<String> status,
  Value<String> priority,
  Value<String> label,
  Value<String> repeatType,
  Value<String?> repeatConfig,
  Value<DateTime> startDateTime,
  Value<DateTime?> dueDateTime,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int?> startNotificationId,
  Value<int?> dueNotificationId,
  Value<bool> isDeleted,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatType => $composableBuilder(
      column: $table.repeatType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeatConfig => $composableBuilder(
      column: $table.repeatConfig, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDateTime => $composableBuilder(
      column: $table.dueDateTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startNotificationId => $composableBuilder(
      column: $table.startNotificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueNotificationId => $composableBuilder(
      column: $table.dueNotificationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatType => $composableBuilder(
      column: $table.repeatType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatConfig => $composableBuilder(
      column: $table.repeatConfig,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDateTime => $composableBuilder(
      column: $table.dueDateTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startNotificationId => $composableBuilder(
      column: $table.startNotificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueNotificationId => $composableBuilder(
      column: $table.dueNotificationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get repeatType => $composableBuilder(
      column: $table.repeatType, builder: (column) => column);

  GeneratedColumn<String> get repeatConfig => $composableBuilder(
      column: $table.repeatConfig, builder: (column) => column);

  GeneratedColumn<DateTime> get startDateTime => $composableBuilder(
      column: $table.startDateTime, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDateTime => $composableBuilder(
      column: $table.dueDateTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get startNotificationId => $composableBuilder(
      column: $table.startNotificationId, builder: (column) => column);

  GeneratedColumn<int> get dueNotificationId => $composableBuilder(
      column: $table.dueNotificationId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> repeatType = const Value.absent(),
            Value<String?> repeatConfig = const Value.absent(),
            Value<DateTime> startDateTime = const Value.absent(),
            Value<DateTime?> dueDateTime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> startNotificationId = const Value.absent(),
            Value<int?> dueNotificationId = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            title: title,
            description: description,
            status: status,
            priority: priority,
            label: label,
            repeatType: repeatType,
            repeatConfig: repeatConfig,
            startDateTime: startDateTime,
            dueDateTime: dueDateTime,
            createdAt: createdAt,
            completedAt: completedAt,
            startNotificationId: startNotificationId,
            dueNotificationId: dueNotificationId,
            isDeleted: isDeleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> repeatType = const Value.absent(),
            Value<String?> repeatConfig = const Value.absent(),
            required DateTime startDateTime,
            Value<DateTime?> dueDateTime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int?> startNotificationId = const Value.absent(),
            Value<int?> dueNotificationId = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            status: status,
            priority: priority,
            label: label,
            repeatType: repeatType,
            repeatConfig: repeatConfig,
            startDateTime: startDateTime,
            dueDateTime: dueDateTime,
            createdAt: createdAt,
            completedAt: completedAt,
            startNotificationId: startNotificationId,
            dueNotificationId: dueNotificationId,
            isDeleted: isDeleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    TaskRow,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
    TaskRow,
    PrefetchHooks Function()>;
typedef $$NotificationLogsTableCreateCompanionBuilder
    = NotificationLogsCompanion Function({
  Value<int> id,
  required int taskId,
  required String message,
  required String kind,
  Value<DateTime> createdAt,
  Value<bool> isRead,
});
typedef $$NotificationLogsTableUpdateCompanionBuilder
    = NotificationLogsCompanion Function({
  Value<int> id,
  Value<int> taskId,
  Value<String> message,
  Value<String> kind,
  Value<DateTime> createdAt,
  Value<bool> isRead,
});

class $$NotificationLogsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));
}

class $$NotificationLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taskId => $composableBuilder(
      column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));
}

class $$NotificationLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogsTable> {
  $$NotificationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$NotificationLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationLogsTable,
    NotificationLogRow,
    $$NotificationLogsTableFilterComposer,
    $$NotificationLogsTableOrderingComposer,
    $$NotificationLogsTableAnnotationComposer,
    $$NotificationLogsTableCreateCompanionBuilder,
    $$NotificationLogsTableUpdateCompanionBuilder,
    (
      NotificationLogRow,
      BaseReferences<_$AppDatabase, $NotificationLogsTable, NotificationLogRow>
    ),
    NotificationLogRow,
    PrefetchHooks Function()> {
  $$NotificationLogsTableTableManager(
      _$AppDatabase db, $NotificationLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> taskId = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
          }) =>
              NotificationLogsCompanion(
            id: id,
            taskId: taskId,
            message: message,
            kind: kind,
            createdAt: createdAt,
            isRead: isRead,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int taskId,
            required String message,
            required String kind,
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
          }) =>
              NotificationLogsCompanion.insert(
            id: id,
            taskId: taskId,
            message: message,
            kind: kind,
            createdAt: createdAt,
            isRead: isRead,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationLogsTable,
    NotificationLogRow,
    $$NotificationLogsTableFilterComposer,
    $$NotificationLogsTableOrderingComposer,
    $$NotificationLogsTableAnnotationComposer,
    $$NotificationLogsTableCreateCompanionBuilder,
    $$NotificationLogsTableUpdateCompanionBuilder,
    (
      NotificationLogRow,
      BaseReferences<_$AppDatabase, $NotificationLogsTable, NotificationLogRow>
    ),
    NotificationLogRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$NotificationLogsTableTableManager get notificationLogs =>
      $$NotificationLogsTableTableManager(_db, _db.notificationLogs);
}
