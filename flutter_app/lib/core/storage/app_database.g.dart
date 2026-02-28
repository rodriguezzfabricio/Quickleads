// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalLeadsTable extends LocalLeads
    with TableInfo<$LocalLeadsTable, LocalLead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalLeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByProfileIdMeta =
      const VerificationMeta('createdByProfileId');
  @override
  late final GeneratedColumn<String> createdByProfileId =
      GeneratedColumn<String>('created_by_profile_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientNameMeta =
      const VerificationMeta('clientName');
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
      'client_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneE164Meta =
      const VerificationMeta('phoneE164');
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
      'phone_e164', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jobTypeMeta =
      const VerificationMeta('jobType');
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
      'job_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('new_callback'));
  static const VerificationMeta _followupStateMeta =
      const VerificationMeta('followupState');
  @override
  late final GeneratedColumn<String> followupState = GeneratedColumn<String>(
      'followup_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _estimateSentAtMeta =
      const VerificationMeta('estimateSentAt');
  @override
  late final GeneratedColumn<DateTime> estimateSentAt =
      GeneratedColumn<DateTime>('estimate_sent_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        createdByProfileId,
        clientName,
        phoneE164,
        email,
        jobType,
        notes,
        status,
        followupState,
        estimateSentAt,
        version,
        createdAt,
        updatedAt,
        deletedAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_leads';
  @override
  VerificationContext validateIntegrity(Insertable<LocalLead> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('created_by_profile_id')) {
      context.handle(
          _createdByProfileIdMeta,
          createdByProfileId.isAcceptableOrUnknown(
              data['created_by_profile_id']!, _createdByProfileIdMeta));
    }
    if (data.containsKey('client_name')) {
      context.handle(
          _clientNameMeta,
          clientName.isAcceptableOrUnknown(
              data['client_name']!, _clientNameMeta));
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('phone_e164')) {
      context.handle(_phoneE164Meta,
          phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('job_type')) {
      context.handle(_jobTypeMeta,
          jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta));
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('followup_state')) {
      context.handle(
          _followupStateMeta,
          followupState.isAcceptableOrUnknown(
              data['followup_state']!, _followupStateMeta));
    }
    if (data.containsKey('estimate_sent_at')) {
      context.handle(
          _estimateSentAtMeta,
          estimateSentAt.isAcceptableOrUnknown(
              data['estimate_sent_at']!, _estimateSentAtMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalLead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalLead(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      createdByProfileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}created_by_profile_id']),
      clientName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_name'])!,
      phoneE164: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_e164']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      jobType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_type'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      followupState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}followup_state'])!,
      estimateSentAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}estimate_sent_at']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalLeadsTable createAlias(String alias) {
    return $LocalLeadsTable(attachedDatabase, alias);
  }
}

class LocalLead extends DataClass implements Insertable<LocalLead> {
  final String id;
  final String organizationId;
  final String? createdByProfileId;
  final String clientName;
  final String? phoneE164;
  final String? email;
  final String jobType;
  final String? notes;
  final String status;
  final String followupState;
  final DateTime? estimateSentAt;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalLead(
      {required this.id,
      required this.organizationId,
      this.createdByProfileId,
      required this.clientName,
      this.phoneE164,
      this.email,
      required this.jobType,
      this.notes,
      required this.status,
      required this.followupState,
      this.estimateSentAt,
      required this.version,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    if (!nullToAbsent || createdByProfileId != null) {
      map['created_by_profile_id'] = Variable<String>(createdByProfileId);
    }
    map['client_name'] = Variable<String>(clientName);
    if (!nullToAbsent || phoneE164 != null) {
      map['phone_e164'] = Variable<String>(phoneE164);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['job_type'] = Variable<String>(jobType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    map['followup_state'] = Variable<String>(followupState);
    if (!nullToAbsent || estimateSentAt != null) {
      map['estimate_sent_at'] = Variable<DateTime>(estimateSentAt);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalLeadsCompanion toCompanion(bool nullToAbsent) {
    return LocalLeadsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      createdByProfileId: createdByProfileId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByProfileId),
      clientName: Value(clientName),
      phoneE164: phoneE164 == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneE164),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      jobType: Value(jobType),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      followupState: Value(followupState),
      estimateSentAt: estimateSentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(estimateSentAt),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalLead.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalLead(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      createdByProfileId:
          serializer.fromJson<String?>(json['createdByProfileId']),
      clientName: serializer.fromJson<String>(json['clientName']),
      phoneE164: serializer.fromJson<String?>(json['phoneE164']),
      email: serializer.fromJson<String?>(json['email']),
      jobType: serializer.fromJson<String>(json['jobType']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      followupState: serializer.fromJson<String>(json['followupState']),
      estimateSentAt: serializer.fromJson<DateTime?>(json['estimateSentAt']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'createdByProfileId': serializer.toJson<String?>(createdByProfileId),
      'clientName': serializer.toJson<String>(clientName),
      'phoneE164': serializer.toJson<String?>(phoneE164),
      'email': serializer.toJson<String?>(email),
      'jobType': serializer.toJson<String>(jobType),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'followupState': serializer.toJson<String>(followupState),
      'estimateSentAt': serializer.toJson<DateTime?>(estimateSentAt),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalLead copyWith(
          {String? id,
          String? organizationId,
          Value<String?> createdByProfileId = const Value.absent(),
          String? clientName,
          Value<String?> phoneE164 = const Value.absent(),
          Value<String?> email = const Value.absent(),
          String? jobType,
          Value<String?> notes = const Value.absent(),
          String? status,
          String? followupState,
          Value<DateTime?> estimateSentAt = const Value.absent(),
          int? version,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalLead(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        createdByProfileId: createdByProfileId.present
            ? createdByProfileId.value
            : this.createdByProfileId,
        clientName: clientName ?? this.clientName,
        phoneE164: phoneE164.present ? phoneE164.value : this.phoneE164,
        email: email.present ? email.value : this.email,
        jobType: jobType ?? this.jobType,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        followupState: followupState ?? this.followupState,
        estimateSentAt:
            estimateSentAt.present ? estimateSentAt.value : this.estimateSentAt,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalLead copyWithCompanion(LocalLeadsCompanion data) {
    return LocalLead(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      createdByProfileId: data.createdByProfileId.present
          ? data.createdByProfileId.value
          : this.createdByProfileId,
      clientName:
          data.clientName.present ? data.clientName.value : this.clientName,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      email: data.email.present ? data.email.value : this.email,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      followupState: data.followupState.present
          ? data.followupState.value
          : this.followupState,
      estimateSentAt: data.estimateSentAt.present
          ? data.estimateSentAt.value
          : this.estimateSentAt,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalLead(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('createdByProfileId: $createdByProfileId, ')
          ..write('clientName: $clientName, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('email: $email, ')
          ..write('jobType: $jobType, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('followupState: $followupState, ')
          ..write('estimateSentAt: $estimateSentAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      organizationId,
      createdByProfileId,
      clientName,
      phoneE164,
      email,
      jobType,
      notes,
      status,
      followupState,
      estimateSentAt,
      version,
      createdAt,
      updatedAt,
      deletedAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalLead &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.createdByProfileId == this.createdByProfileId &&
          other.clientName == this.clientName &&
          other.phoneE164 == this.phoneE164 &&
          other.email == this.email &&
          other.jobType == this.jobType &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.followupState == this.followupState &&
          other.estimateSentAt == this.estimateSentAt &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalLeadsCompanion extends UpdateCompanion<LocalLead> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String?> createdByProfileId;
  final Value<String> clientName;
  final Value<String?> phoneE164;
  final Value<String?> email;
  final Value<String> jobType;
  final Value<String?> notes;
  final Value<String> status;
  final Value<String> followupState;
  final Value<DateTime?> estimateSentAt;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalLeadsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.createdByProfileId = const Value.absent(),
    this.clientName = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.email = const Value.absent(),
    this.jobType = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.followupState = const Value.absent(),
    this.estimateSentAt = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalLeadsCompanion.insert({
    required String id,
    required String organizationId,
    this.createdByProfileId = const Value.absent(),
    required String clientName,
    this.phoneE164 = const Value.absent(),
    this.email = const Value.absent(),
    required String jobType,
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.followupState = const Value.absent(),
    this.estimateSentAt = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        clientName = Value(clientName),
        jobType = Value(jobType);
  static Insertable<LocalLead> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? createdByProfileId,
    Expression<String>? clientName,
    Expression<String>? phoneE164,
    Expression<String>? email,
    Expression<String>? jobType,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? followupState,
    Expression<DateTime>? estimateSentAt,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (createdByProfileId != null)
        'created_by_profile_id': createdByProfileId,
      if (clientName != null) 'client_name': clientName,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (email != null) 'email': email,
      if (jobType != null) 'job_type': jobType,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (followupState != null) 'followup_state': followupState,
      if (estimateSentAt != null) 'estimate_sent_at': estimateSentAt,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalLeadsCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String?>? createdByProfileId,
      Value<String>? clientName,
      Value<String?>? phoneE164,
      Value<String?>? email,
      Value<String>? jobType,
      Value<String?>? notes,
      Value<String>? status,
      Value<String>? followupState,
      Value<DateTime?>? estimateSentAt,
      Value<int>? version,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalLeadsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      clientName: clientName ?? this.clientName,
      phoneE164: phoneE164 ?? this.phoneE164,
      email: email ?? this.email,
      jobType: jobType ?? this.jobType,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      followupState: followupState ?? this.followupState,
      estimateSentAt: estimateSentAt ?? this.estimateSentAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (createdByProfileId.present) {
      map['created_by_profile_id'] = Variable<String>(createdByProfileId.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (followupState.present) {
      map['followup_state'] = Variable<String>(followupState.value);
    }
    if (estimateSentAt.present) {
      map['estimate_sent_at'] = Variable<DateTime>(estimateSentAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalLeadsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('createdByProfileId: $createdByProfileId, ')
          ..write('clientName: $clientName, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('email: $email, ')
          ..write('jobType: $jobType, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('followupState: $followupState, ')
          ..write('estimateSentAt: $estimateSentAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalJobsTable extends LocalJobs
    with TableInfo<$LocalJobsTable, LocalJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
      'lead_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clientNameMeta =
      const VerificationMeta('clientName');
  @override
  late final GeneratedColumn<String> clientName = GeneratedColumn<String>(
      'client_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _jobTypeMeta =
      const VerificationMeta('jobType');
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
      'job_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
      'phase', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('demo'));
  static const VerificationMeta _healthStatusMeta =
      const VerificationMeta('healthStatus');
  @override
  late final GeneratedColumn<String> healthStatus = GeneratedColumn<String>(
      'health_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('green'));
  static const VerificationMeta _estimatedCompletionDateMeta =
      const VerificationMeta('estimatedCompletionDate');
  @override
  late final GeneratedColumn<DateTime> estimatedCompletionDate =
      GeneratedColumn<DateTime>('estimated_completion_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        leadId,
        clientName,
        jobType,
        phase,
        healthStatus,
        estimatedCompletionDate,
        version,
        createdAt,
        updatedAt,
        deletedAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(_leadIdMeta,
          leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta));
    }
    if (data.containsKey('client_name')) {
      context.handle(
          _clientNameMeta,
          clientName.isAcceptableOrUnknown(
              data['client_name']!, _clientNameMeta));
    } else if (isInserting) {
      context.missing(_clientNameMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(_jobTypeMeta,
          jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta));
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('phase')) {
      context.handle(
          _phaseMeta, phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta));
    }
    if (data.containsKey('health_status')) {
      context.handle(
          _healthStatusMeta,
          healthStatus.isAcceptableOrUnknown(
              data['health_status']!, _healthStatusMeta));
    }
    if (data.containsKey('estimated_completion_date')) {
      context.handle(
          _estimatedCompletionDateMeta,
          estimatedCompletionDate.isAcceptableOrUnknown(
              data['estimated_completion_date']!,
              _estimatedCompletionDateMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      leadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lead_id']),
      clientName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_name'])!,
      jobType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}job_type'])!,
      phase: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phase'])!,
      healthStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}health_status'])!,
      estimatedCompletionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}estimated_completion_date']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalJobsTable createAlias(String alias) {
    return $LocalJobsTable(attachedDatabase, alias);
  }
}

class LocalJob extends DataClass implements Insertable<LocalJob> {
  final String id;
  final String organizationId;
  final String? leadId;
  final String clientName;
  final String jobType;
  final String phase;
  final String healthStatus;
  final DateTime? estimatedCompletionDate;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalJob(
      {required this.id,
      required this.organizationId,
      this.leadId,
      required this.clientName,
      required this.jobType,
      required this.phase,
      required this.healthStatus,
      this.estimatedCompletionDate,
      required this.version,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    if (!nullToAbsent || leadId != null) {
      map['lead_id'] = Variable<String>(leadId);
    }
    map['client_name'] = Variable<String>(clientName);
    map['job_type'] = Variable<String>(jobType);
    map['phase'] = Variable<String>(phase);
    map['health_status'] = Variable<String>(healthStatus);
    if (!nullToAbsent || estimatedCompletionDate != null) {
      map['estimated_completion_date'] =
          Variable<DateTime>(estimatedCompletionDate);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalJobsCompanion toCompanion(bool nullToAbsent) {
    return LocalJobsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      leadId:
          leadId == null && nullToAbsent ? const Value.absent() : Value(leadId),
      clientName: Value(clientName),
      jobType: Value(jobType),
      phase: Value(phase),
      healthStatus: Value(healthStatus),
      estimatedCompletionDate: estimatedCompletionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCompletionDate),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalJob(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      leadId: serializer.fromJson<String?>(json['leadId']),
      clientName: serializer.fromJson<String>(json['clientName']),
      jobType: serializer.fromJson<String>(json['jobType']),
      phase: serializer.fromJson<String>(json['phase']),
      healthStatus: serializer.fromJson<String>(json['healthStatus']),
      estimatedCompletionDate:
          serializer.fromJson<DateTime?>(json['estimatedCompletionDate']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'leadId': serializer.toJson<String?>(leadId),
      'clientName': serializer.toJson<String>(clientName),
      'jobType': serializer.toJson<String>(jobType),
      'phase': serializer.toJson<String>(phase),
      'healthStatus': serializer.toJson<String>(healthStatus),
      'estimatedCompletionDate':
          serializer.toJson<DateTime?>(estimatedCompletionDate),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalJob copyWith(
          {String? id,
          String? organizationId,
          Value<String?> leadId = const Value.absent(),
          String? clientName,
          String? jobType,
          String? phase,
          String? healthStatus,
          Value<DateTime?> estimatedCompletionDate = const Value.absent(),
          int? version,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalJob(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        leadId: leadId.present ? leadId.value : this.leadId,
        clientName: clientName ?? this.clientName,
        jobType: jobType ?? this.jobType,
        phase: phase ?? this.phase,
        healthStatus: healthStatus ?? this.healthStatus,
        estimatedCompletionDate: estimatedCompletionDate.present
            ? estimatedCompletionDate.value
            : this.estimatedCompletionDate,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalJob copyWithCompanion(LocalJobsCompanion data) {
    return LocalJob(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      clientName:
          data.clientName.present ? data.clientName.value : this.clientName,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      phase: data.phase.present ? data.phase.value : this.phase,
      healthStatus: data.healthStatus.present
          ? data.healthStatus.value
          : this.healthStatus,
      estimatedCompletionDate: data.estimatedCompletionDate.present
          ? data.estimatedCompletionDate.value
          : this.estimatedCompletionDate,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalJob(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('clientName: $clientName, ')
          ..write('jobType: $jobType, ')
          ..write('phase: $phase, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('estimatedCompletionDate: $estimatedCompletionDate, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      organizationId,
      leadId,
      clientName,
      jobType,
      phase,
      healthStatus,
      estimatedCompletionDate,
      version,
      createdAt,
      updatedAt,
      deletedAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalJob &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.leadId == this.leadId &&
          other.clientName == this.clientName &&
          other.jobType == this.jobType &&
          other.phase == this.phase &&
          other.healthStatus == this.healthStatus &&
          other.estimatedCompletionDate == this.estimatedCompletionDate &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalJobsCompanion extends UpdateCompanion<LocalJob> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String?> leadId;
  final Value<String> clientName;
  final Value<String> jobType;
  final Value<String> phase;
  final Value<String> healthStatus;
  final Value<DateTime?> estimatedCompletionDate;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalJobsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.leadId = const Value.absent(),
    this.clientName = const Value.absent(),
    this.jobType = const Value.absent(),
    this.phase = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.estimatedCompletionDate = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalJobsCompanion.insert({
    required String id,
    required String organizationId,
    this.leadId = const Value.absent(),
    required String clientName,
    required String jobType,
    this.phase = const Value.absent(),
    this.healthStatus = const Value.absent(),
    this.estimatedCompletionDate = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        clientName = Value(clientName),
        jobType = Value(jobType);
  static Insertable<LocalJob> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? leadId,
    Expression<String>? clientName,
    Expression<String>? jobType,
    Expression<String>? phase,
    Expression<String>? healthStatus,
    Expression<DateTime>? estimatedCompletionDate,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (leadId != null) 'lead_id': leadId,
      if (clientName != null) 'client_name': clientName,
      if (jobType != null) 'job_type': jobType,
      if (phase != null) 'phase': phase,
      if (healthStatus != null) 'health_status': healthStatus,
      if (estimatedCompletionDate != null)
        'estimated_completion_date': estimatedCompletionDate,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalJobsCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String?>? leadId,
      Value<String>? clientName,
      Value<String>? jobType,
      Value<String>? phase,
      Value<String>? healthStatus,
      Value<DateTime?>? estimatedCompletionDate,
      Value<int>? version,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalJobsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      leadId: leadId ?? this.leadId,
      clientName: clientName ?? this.clientName,
      jobType: jobType ?? this.jobType,
      phase: phase ?? this.phase,
      healthStatus: healthStatus ?? this.healthStatus,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (clientName.present) {
      map['client_name'] = Variable<String>(clientName.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (healthStatus.present) {
      map['health_status'] = Variable<String>(healthStatus.value);
    }
    if (estimatedCompletionDate.present) {
      map['estimated_completion_date'] =
          Variable<DateTime>(estimatedCompletionDate.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalJobsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('clientName: $clientName, ')
          ..write('jobType: $jobType, ')
          ..write('phase: $phase, ')
          ..write('healthStatus: $healthStatus, ')
          ..write('estimatedCompletionDate: $estimatedCompletionDate, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFollowupSequencesTable extends LocalFollowupSequences
    with TableInfo<$LocalFollowupSequencesTable, LocalFollowupSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFollowupSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
      'lead_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
      'state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _startDateLocalMeta =
      const VerificationMeta('startDateLocal');
  @override
  late final GeneratedColumn<DateTime> startDateLocal =
      GeneratedColumn<DateTime>('start_date_local', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nextSendAtMeta =
      const VerificationMeta('nextSendAt');
  @override
  late final GeneratedColumn<DateTime> nextSendAt = GeneratedColumn<DateTime>(
      'next_send_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _pausedAtMeta =
      const VerificationMeta('pausedAt');
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
      'paused_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _stoppedAtMeta =
      const VerificationMeta('stoppedAt');
  @override
  late final GeneratedColumn<DateTime> stoppedAt = GeneratedColumn<DateTime>(
      'stopped_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        leadId,
        state,
        startDateLocal,
        timezone,
        nextSendAt,
        createdAt,
        updatedAt,
        pausedAt,
        stoppedAt,
        completedAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_followup_sequences';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalFollowupSequence> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(_leadIdMeta,
          leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta));
    } else if (isInserting) {
      context.missing(_leadIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    }
    if (data.containsKey('start_date_local')) {
      context.handle(
          _startDateLocalMeta,
          startDateLocal.isAcceptableOrUnknown(
              data['start_date_local']!, _startDateLocalMeta));
    } else if (isInserting) {
      context.missing(_startDateLocalMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('next_send_at')) {
      context.handle(
          _nextSendAtMeta,
          nextSendAt.isAcceptableOrUnknown(
              data['next_send_at']!, _nextSendAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('paused_at')) {
      context.handle(_pausedAtMeta,
          pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta));
    }
    if (data.containsKey('stopped_at')) {
      context.handle(_stoppedAtMeta,
          stoppedAt.isAcceptableOrUnknown(data['stopped_at']!, _stoppedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFollowupSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFollowupSequence(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      leadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lead_id'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}state'])!,
      startDateLocal: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}start_date_local'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      nextSendAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_send_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      pausedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}paused_at']),
      stoppedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}stopped_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalFollowupSequencesTable createAlias(String alias) {
    return $LocalFollowupSequencesTable(attachedDatabase, alias);
  }
}

class LocalFollowupSequence extends DataClass
    implements Insertable<LocalFollowupSequence> {
  final String id;
  final String organizationId;
  final String leadId;
  final String state;
  final DateTime startDateLocal;
  final String timezone;
  final DateTime? nextSendAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? pausedAt;
  final DateTime? stoppedAt;
  final DateTime? completedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalFollowupSequence(
      {required this.id,
      required this.organizationId,
      required this.leadId,
      required this.state,
      required this.startDateLocal,
      required this.timezone,
      this.nextSendAt,
      required this.createdAt,
      required this.updatedAt,
      this.pausedAt,
      this.stoppedAt,
      this.completedAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['lead_id'] = Variable<String>(leadId);
    map['state'] = Variable<String>(state);
    map['start_date_local'] = Variable<DateTime>(startDateLocal);
    map['timezone'] = Variable<String>(timezone);
    if (!nullToAbsent || nextSendAt != null) {
      map['next_send_at'] = Variable<DateTime>(nextSendAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    if (!nullToAbsent || stoppedAt != null) {
      map['stopped_at'] = Variable<DateTime>(stoppedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalFollowupSequencesCompanion toCompanion(bool nullToAbsent) {
    return LocalFollowupSequencesCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      leadId: Value(leadId),
      state: Value(state),
      startDateLocal: Value(startDateLocal),
      timezone: Value(timezone),
      nextSendAt: nextSendAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextSendAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      stoppedAt: stoppedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(stoppedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalFollowupSequence.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFollowupSequence(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      leadId: serializer.fromJson<String>(json['leadId']),
      state: serializer.fromJson<String>(json['state']),
      startDateLocal: serializer.fromJson<DateTime>(json['startDateLocal']),
      timezone: serializer.fromJson<String>(json['timezone']),
      nextSendAt: serializer.fromJson<DateTime?>(json['nextSendAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      stoppedAt: serializer.fromJson<DateTime?>(json['stoppedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'leadId': serializer.toJson<String>(leadId),
      'state': serializer.toJson<String>(state),
      'startDateLocal': serializer.toJson<DateTime>(startDateLocal),
      'timezone': serializer.toJson<String>(timezone),
      'nextSendAt': serializer.toJson<DateTime?>(nextSendAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'stoppedAt': serializer.toJson<DateTime?>(stoppedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalFollowupSequence copyWith(
          {String? id,
          String? organizationId,
          String? leadId,
          String? state,
          DateTime? startDateLocal,
          String? timezone,
          Value<DateTime?> nextSendAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> pausedAt = const Value.absent(),
          Value<DateTime?> stoppedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalFollowupSequence(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        leadId: leadId ?? this.leadId,
        state: state ?? this.state,
        startDateLocal: startDateLocal ?? this.startDateLocal,
        timezone: timezone ?? this.timezone,
        nextSendAt: nextSendAt.present ? nextSendAt.value : this.nextSendAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
        stoppedAt: stoppedAt.present ? stoppedAt.value : this.stoppedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalFollowupSequence copyWithCompanion(
      LocalFollowupSequencesCompanion data) {
    return LocalFollowupSequence(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      state: data.state.present ? data.state.value : this.state,
      startDateLocal: data.startDateLocal.present
          ? data.startDateLocal.value
          : this.startDateLocal,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      nextSendAt:
          data.nextSendAt.present ? data.nextSendAt.value : this.nextSendAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      stoppedAt: data.stoppedAt.present ? data.stoppedAt.value : this.stoppedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFollowupSequence(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('state: $state, ')
          ..write('startDateLocal: $startDateLocal, ')
          ..write('timezone: $timezone, ')
          ..write('nextSendAt: $nextSendAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('stoppedAt: $stoppedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      organizationId,
      leadId,
      state,
      startDateLocal,
      timezone,
      nextSendAt,
      createdAt,
      updatedAt,
      pausedAt,
      stoppedAt,
      completedAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFollowupSequence &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.leadId == this.leadId &&
          other.state == this.state &&
          other.startDateLocal == this.startDateLocal &&
          other.timezone == this.timezone &&
          other.nextSendAt == this.nextSendAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.pausedAt == this.pausedAt &&
          other.stoppedAt == this.stoppedAt &&
          other.completedAt == this.completedAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalFollowupSequencesCompanion
    extends UpdateCompanion<LocalFollowupSequence> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> leadId;
  final Value<String> state;
  final Value<DateTime> startDateLocal;
  final Value<String> timezone;
  final Value<DateTime?> nextSendAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> pausedAt;
  final Value<DateTime?> stoppedAt;
  final Value<DateTime?> completedAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalFollowupSequencesCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.leadId = const Value.absent(),
    this.state = const Value.absent(),
    this.startDateLocal = const Value.absent(),
    this.timezone = const Value.absent(),
    this.nextSendAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.stoppedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFollowupSequencesCompanion.insert({
    required String id,
    required String organizationId,
    required String leadId,
    this.state = const Value.absent(),
    required DateTime startDateLocal,
    required String timezone,
    this.nextSendAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.stoppedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        leadId = Value(leadId),
        startDateLocal = Value(startDateLocal),
        timezone = Value(timezone);
  static Insertable<LocalFollowupSequence> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? leadId,
    Expression<String>? state,
    Expression<DateTime>? startDateLocal,
    Expression<String>? timezone,
    Expression<DateTime>? nextSendAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? pausedAt,
    Expression<DateTime>? stoppedAt,
    Expression<DateTime>? completedAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (leadId != null) 'lead_id': leadId,
      if (state != null) 'state': state,
      if (startDateLocal != null) 'start_date_local': startDateLocal,
      if (timezone != null) 'timezone': timezone,
      if (nextSendAt != null) 'next_send_at': nextSendAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (stoppedAt != null) 'stopped_at': stoppedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFollowupSequencesCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String>? leadId,
      Value<String>? state,
      Value<DateTime>? startDateLocal,
      Value<String>? timezone,
      Value<DateTime?>? nextSendAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? pausedAt,
      Value<DateTime?>? stoppedAt,
      Value<DateTime?>? completedAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalFollowupSequencesCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      leadId: leadId ?? this.leadId,
      state: state ?? this.state,
      startDateLocal: startDateLocal ?? this.startDateLocal,
      timezone: timezone ?? this.timezone,
      nextSendAt: nextSendAt ?? this.nextSendAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      stoppedAt: stoppedAt ?? this.stoppedAt,
      completedAt: completedAt ?? this.completedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (startDateLocal.present) {
      map['start_date_local'] = Variable<DateTime>(startDateLocal.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (nextSendAt.present) {
      map['next_send_at'] = Variable<DateTime>(nextSendAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (stoppedAt.present) {
      map['stopped_at'] = Variable<DateTime>(stoppedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFollowupSequencesCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('state: $state, ')
          ..write('startDateLocal: $startDateLocal, ')
          ..write('timezone: $timezone, ')
          ..write('nextSendAt: $nextSendAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('stoppedAt: $stoppedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFollowupMessagesTable extends LocalFollowupMessages
    with TableInfo<$LocalFollowupMessagesTable, LocalFollowupMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFollowupMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sequenceIdMeta =
      const VerificationMeta('sequenceId');
  @override
  late final GeneratedColumn<String> sequenceId = GeneratedColumn<String>(
      'sequence_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepNumberMeta =
      const VerificationMeta('stepNumber');
  @override
  late final GeneratedColumn<int> stepNumber = GeneratedColumn<int>(
      'step_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _channelMeta =
      const VerificationMeta('channel');
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
      'channel', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateKeyMeta =
      const VerificationMeta('templateKey');
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
      'template_key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('queued'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _providerMessageIdMeta =
      const VerificationMeta('providerMessageId');
  @override
  late final GeneratedColumn<String> providerMessageId =
      GeneratedColumn<String>('provider_message_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sequenceId,
        stepNumber,
        channel,
        templateKey,
        scheduledAt,
        sentAt,
        status,
        retryCount,
        providerMessageId,
        errorMessage,
        createdAt,
        updatedAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_followup_messages';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalFollowupMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sequence_id')) {
      context.handle(
          _sequenceIdMeta,
          sequenceId.isAcceptableOrUnknown(
              data['sequence_id']!, _sequenceIdMeta));
    } else if (isInserting) {
      context.missing(_sequenceIdMeta);
    }
    if (data.containsKey('step_number')) {
      context.handle(
          _stepNumberMeta,
          stepNumber.isAcceptableOrUnknown(
              data['step_number']!, _stepNumberMeta));
    } else if (isInserting) {
      context.missing(_stepNumberMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(_channelMeta,
          channel.isAcceptableOrUnknown(data['channel']!, _channelMeta));
    } else if (isInserting) {
      context.missing(_channelMeta);
    }
    if (data.containsKey('template_key')) {
      context.handle(
          _templateKeyMeta,
          templateKey.isAcceptableOrUnknown(
              data['template_key']!, _templateKeyMeta));
    } else if (isInserting) {
      context.missing(_templateKeyMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('provider_message_id')) {
      context.handle(
          _providerMessageIdMeta,
          providerMessageId.isAcceptableOrUnknown(
              data['provider_message_id']!, _providerMessageIdMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFollowupMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFollowupMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sequenceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sequence_id'])!,
      stepNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}step_number'])!,
      channel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}channel'])!,
      templateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_key'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      providerMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}provider_message_id']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalFollowupMessagesTable createAlias(String alias) {
    return $LocalFollowupMessagesTable(attachedDatabase, alias);
  }
}

class LocalFollowupMessage extends DataClass
    implements Insertable<LocalFollowupMessage> {
  final String id;
  final String sequenceId;
  final int stepNumber;
  final String channel;
  final String templateKey;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final String status;
  final int retryCount;
  final String? providerMessageId;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalFollowupMessage(
      {required this.id,
      required this.sequenceId,
      required this.stepNumber,
      required this.channel,
      required this.templateKey,
      required this.scheduledAt,
      this.sentAt,
      required this.status,
      required this.retryCount,
      this.providerMessageId,
      this.errorMessage,
      required this.createdAt,
      required this.updatedAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sequence_id'] = Variable<String>(sequenceId);
    map['step_number'] = Variable<int>(stepNumber);
    map['channel'] = Variable<String>(channel);
    map['template_key'] = Variable<String>(templateKey);
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || providerMessageId != null) {
      map['provider_message_id'] = Variable<String>(providerMessageId);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalFollowupMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalFollowupMessagesCompanion(
      id: Value(id),
      sequenceId: Value(sequenceId),
      stepNumber: Value(stepNumber),
      channel: Value(channel),
      templateKey: Value(templateKey),
      scheduledAt: Value(scheduledAt),
      sentAt:
          sentAt == null && nullToAbsent ? const Value.absent() : Value(sentAt),
      status: Value(status),
      retryCount: Value(retryCount),
      providerMessageId: providerMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerMessageId),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalFollowupMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFollowupMessage(
      id: serializer.fromJson<String>(json['id']),
      sequenceId: serializer.fromJson<String>(json['sequenceId']),
      stepNumber: serializer.fromJson<int>(json['stepNumber']),
      channel: serializer.fromJson<String>(json['channel']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      providerMessageId:
          serializer.fromJson<String?>(json['providerMessageId']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sequenceId': serializer.toJson<String>(sequenceId),
      'stepNumber': serializer.toJson<int>(stepNumber),
      'channel': serializer.toJson<String>(channel),
      'templateKey': serializer.toJson<String>(templateKey),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'providerMessageId': serializer.toJson<String?>(providerMessageId),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalFollowupMessage copyWith(
          {String? id,
          String? sequenceId,
          int? stepNumber,
          String? channel,
          String? templateKey,
          DateTime? scheduledAt,
          Value<DateTime?> sentAt = const Value.absent(),
          String? status,
          int? retryCount,
          Value<String?> providerMessageId = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalFollowupMessage(
        id: id ?? this.id,
        sequenceId: sequenceId ?? this.sequenceId,
        stepNumber: stepNumber ?? this.stepNumber,
        channel: channel ?? this.channel,
        templateKey: templateKey ?? this.templateKey,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        sentAt: sentAt.present ? sentAt.value : this.sentAt,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        providerMessageId: providerMessageId.present
            ? providerMessageId.value
            : this.providerMessageId,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalFollowupMessage copyWithCompanion(LocalFollowupMessagesCompanion data) {
    return LocalFollowupMessage(
      id: data.id.present ? data.id.value : this.id,
      sequenceId:
          data.sequenceId.present ? data.sequenceId.value : this.sequenceId,
      stepNumber:
          data.stepNumber.present ? data.stepNumber.value : this.stepNumber,
      channel: data.channel.present ? data.channel.value : this.channel,
      templateKey:
          data.templateKey.present ? data.templateKey.value : this.templateKey,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      providerMessageId: data.providerMessageId.present
          ? data.providerMessageId.value
          : this.providerMessageId,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFollowupMessage(')
          ..write('id: $id, ')
          ..write('sequenceId: $sequenceId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('channel: $channel, ')
          ..write('templateKey: $templateKey, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('providerMessageId: $providerMessageId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sequenceId,
      stepNumber,
      channel,
      templateKey,
      scheduledAt,
      sentAt,
      status,
      retryCount,
      providerMessageId,
      errorMessage,
      createdAt,
      updatedAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFollowupMessage &&
          other.id == this.id &&
          other.sequenceId == this.sequenceId &&
          other.stepNumber == this.stepNumber &&
          other.channel == this.channel &&
          other.templateKey == this.templateKey &&
          other.scheduledAt == this.scheduledAt &&
          other.sentAt == this.sentAt &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.providerMessageId == this.providerMessageId &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalFollowupMessagesCompanion
    extends UpdateCompanion<LocalFollowupMessage> {
  final Value<String> id;
  final Value<String> sequenceId;
  final Value<int> stepNumber;
  final Value<String> channel;
  final Value<String> templateKey;
  final Value<DateTime> scheduledAt;
  final Value<DateTime?> sentAt;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> providerMessageId;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalFollowupMessagesCompanion({
    this.id = const Value.absent(),
    this.sequenceId = const Value.absent(),
    this.stepNumber = const Value.absent(),
    this.channel = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.providerMessageId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFollowupMessagesCompanion.insert({
    required String id,
    required String sequenceId,
    required int stepNumber,
    required String channel,
    required String templateKey,
    required DateTime scheduledAt,
    this.sentAt = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.providerMessageId = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sequenceId = Value(sequenceId),
        stepNumber = Value(stepNumber),
        channel = Value(channel),
        templateKey = Value(templateKey),
        scheduledAt = Value(scheduledAt);
  static Insertable<LocalFollowupMessage> custom({
    Expression<String>? id,
    Expression<String>? sequenceId,
    Expression<int>? stepNumber,
    Expression<String>? channel,
    Expression<String>? templateKey,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? sentAt,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? providerMessageId,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sequenceId != null) 'sequence_id': sequenceId,
      if (stepNumber != null) 'step_number': stepNumber,
      if (channel != null) 'channel': channel,
      if (templateKey != null) 'template_key': templateKey,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (providerMessageId != null) 'provider_message_id': providerMessageId,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFollowupMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sequenceId,
      Value<int>? stepNumber,
      Value<String>? channel,
      Value<String>? templateKey,
      Value<DateTime>? scheduledAt,
      Value<DateTime?>? sentAt,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? providerMessageId,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalFollowupMessagesCompanion(
      id: id ?? this.id,
      sequenceId: sequenceId ?? this.sequenceId,
      stepNumber: stepNumber ?? this.stepNumber,
      channel: channel ?? this.channel,
      templateKey: templateKey ?? this.templateKey,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      providerMessageId: providerMessageId ?? this.providerMessageId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sequenceId.present) {
      map['sequence_id'] = Variable<String>(sequenceId.value);
    }
    if (stepNumber.present) {
      map['step_number'] = Variable<int>(stepNumber.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (providerMessageId.present) {
      map['provider_message_id'] = Variable<String>(providerMessageId.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFollowupMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sequenceId: $sequenceId, ')
          ..write('stepNumber: $stepNumber, ')
          ..write('channel: $channel, ')
          ..write('templateKey: $templateKey, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('providerMessageId: $providerMessageId, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCallLogsTable extends LocalCallLogs
    with TableInfo<$LocalCallLogsTable, LocalCallLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _leadIdMeta = const VerificationMeta('leadId');
  @override
  late final GeneratedColumn<String> leadId = GeneratedColumn<String>(
      'lead_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneE164Meta =
      const VerificationMeta('phoneE164');
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
      'phone_e164', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _durationSecMeta =
      const VerificationMeta('durationSec');
  @override
  late final GeneratedColumn<int> durationSec = GeneratedColumn<int>(
      'duration_sec', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dispositionMeta =
      const VerificationMeta('disposition');
  @override
  late final GeneratedColumn<String> disposition = GeneratedColumn<String>(
      'disposition', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        leadId,
        phoneE164,
        platform,
        source,
        startedAt,
        durationSec,
        disposition,
        createdAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_call_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalCallLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('lead_id')) {
      context.handle(_leadIdMeta,
          leadId.isAcceptableOrUnknown(data['lead_id']!, _leadIdMeta));
    }
    if (data.containsKey('phone_e164')) {
      context.handle(_phoneE164Meta,
          phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta));
    } else if (isInserting) {
      context.missing(_phoneE164Meta);
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('duration_sec')) {
      context.handle(
          _durationSecMeta,
          durationSec.isAcceptableOrUnknown(
              data['duration_sec']!, _durationSecMeta));
    }
    if (data.containsKey('disposition')) {
      context.handle(
          _dispositionMeta,
          disposition.isAcceptableOrUnknown(
              data['disposition']!, _dispositionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCallLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCallLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      leadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lead_id']),
      phoneE164: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_e164'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      durationSec: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_sec'])!,
      disposition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disposition'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalCallLogsTable createAlias(String alias) {
    return $LocalCallLogsTable(attachedDatabase, alias);
  }
}

class LocalCallLog extends DataClass implements Insertable<LocalCallLog> {
  final String id;
  final String organizationId;
  final String? leadId;
  final String phoneE164;
  final String platform;
  final String source;
  final DateTime startedAt;
  final int durationSec;
  final String disposition;
  final DateTime createdAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalCallLog(
      {required this.id,
      required this.organizationId,
      this.leadId,
      required this.phoneE164,
      required this.platform,
      required this.source,
      required this.startedAt,
      required this.durationSec,
      required this.disposition,
      required this.createdAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    if (!nullToAbsent || leadId != null) {
      map['lead_id'] = Variable<String>(leadId);
    }
    map['phone_e164'] = Variable<String>(phoneE164);
    map['platform'] = Variable<String>(platform);
    map['source'] = Variable<String>(source);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['duration_sec'] = Variable<int>(durationSec);
    map['disposition'] = Variable<String>(disposition);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalCallLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalCallLogsCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      leadId:
          leadId == null && nullToAbsent ? const Value.absent() : Value(leadId),
      phoneE164: Value(phoneE164),
      platform: Value(platform),
      source: Value(source),
      startedAt: Value(startedAt),
      durationSec: Value(durationSec),
      disposition: Value(disposition),
      createdAt: Value(createdAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalCallLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCallLog(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      leadId: serializer.fromJson<String?>(json['leadId']),
      phoneE164: serializer.fromJson<String>(json['phoneE164']),
      platform: serializer.fromJson<String>(json['platform']),
      source: serializer.fromJson<String>(json['source']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      durationSec: serializer.fromJson<int>(json['durationSec']),
      disposition: serializer.fromJson<String>(json['disposition']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'leadId': serializer.toJson<String?>(leadId),
      'phoneE164': serializer.toJson<String>(phoneE164),
      'platform': serializer.toJson<String>(platform),
      'source': serializer.toJson<String>(source),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'durationSec': serializer.toJson<int>(durationSec),
      'disposition': serializer.toJson<String>(disposition),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalCallLog copyWith(
          {String? id,
          String? organizationId,
          Value<String?> leadId = const Value.absent(),
          String? phoneE164,
          String? platform,
          String? source,
          DateTime? startedAt,
          int? durationSec,
          String? disposition,
          DateTime? createdAt,
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalCallLog(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        leadId: leadId.present ? leadId.value : this.leadId,
        phoneE164: phoneE164 ?? this.phoneE164,
        platform: platform ?? this.platform,
        source: source ?? this.source,
        startedAt: startedAt ?? this.startedAt,
        durationSec: durationSec ?? this.durationSec,
        disposition: disposition ?? this.disposition,
        createdAt: createdAt ?? this.createdAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalCallLog copyWithCompanion(LocalCallLogsCompanion data) {
    return LocalCallLog(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      leadId: data.leadId.present ? data.leadId.value : this.leadId,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      platform: data.platform.present ? data.platform.value : this.platform,
      source: data.source.present ? data.source.value : this.source,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      durationSec:
          data.durationSec.present ? data.durationSec.value : this.durationSec,
      disposition:
          data.disposition.present ? data.disposition.value : this.disposition,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCallLog(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('platform: $platform, ')
          ..write('source: $source, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('disposition: $disposition, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      organizationId,
      leadId,
      phoneE164,
      platform,
      source,
      startedAt,
      durationSec,
      disposition,
      createdAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCallLog &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.leadId == this.leadId &&
          other.phoneE164 == this.phoneE164 &&
          other.platform == this.platform &&
          other.source == this.source &&
          other.startedAt == this.startedAt &&
          other.durationSec == this.durationSec &&
          other.disposition == this.disposition &&
          other.createdAt == this.createdAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalCallLogsCompanion extends UpdateCompanion<LocalCallLog> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String?> leadId;
  final Value<String> phoneE164;
  final Value<String> platform;
  final Value<String> source;
  final Value<DateTime> startedAt;
  final Value<int> durationSec;
  final Value<String> disposition;
  final Value<DateTime> createdAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalCallLogsCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.leadId = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.platform = const Value.absent(),
    this.source = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.durationSec = const Value.absent(),
    this.disposition = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCallLogsCompanion.insert({
    required String id,
    required String organizationId,
    this.leadId = const Value.absent(),
    required String phoneE164,
    required String platform,
    required String source,
    required DateTime startedAt,
    this.durationSec = const Value.absent(),
    this.disposition = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        phoneE164 = Value(phoneE164),
        platform = Value(platform),
        source = Value(source),
        startedAt = Value(startedAt);
  static Insertable<LocalCallLog> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? leadId,
    Expression<String>? phoneE164,
    Expression<String>? platform,
    Expression<String>? source,
    Expression<DateTime>? startedAt,
    Expression<int>? durationSec,
    Expression<String>? disposition,
    Expression<DateTime>? createdAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (leadId != null) 'lead_id': leadId,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (platform != null) 'platform': platform,
      if (source != null) 'source': source,
      if (startedAt != null) 'started_at': startedAt,
      if (durationSec != null) 'duration_sec': durationSec,
      if (disposition != null) 'disposition': disposition,
      if (createdAt != null) 'created_at': createdAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCallLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String?>? leadId,
      Value<String>? phoneE164,
      Value<String>? platform,
      Value<String>? source,
      Value<DateTime>? startedAt,
      Value<int>? durationSec,
      Value<String>? disposition,
      Value<DateTime>? createdAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalCallLogsCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      leadId: leadId ?? this.leadId,
      phoneE164: phoneE164 ?? this.phoneE164,
      platform: platform ?? this.platform,
      source: source ?? this.source,
      startedAt: startedAt ?? this.startedAt,
      durationSec: durationSec ?? this.durationSec,
      disposition: disposition ?? this.disposition,
      createdAt: createdAt ?? this.createdAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (leadId.present) {
      map['lead_id'] = Variable<String>(leadId.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (durationSec.present) {
      map['duration_sec'] = Variable<int>(durationSec.value);
    }
    if (disposition.present) {
      map['disposition'] = Variable<String>(disposition.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCallLogsCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('leadId: $leadId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('platform: $platform, ')
          ..write('source: $source, ')
          ..write('startedAt: $startedAt, ')
          ..write('durationSec: $durationSec, ')
          ..write('disposition: $disposition, ')
          ..write('createdAt: $createdAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMessageTemplatesTable extends LocalMessageTemplates
    with TableInfo<$LocalMessageTemplatesTable, LocalMessageTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessageTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateKeyMeta =
      const VerificationMeta('templateKey');
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
      'template_key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _smsBodyMeta =
      const VerificationMeta('smsBody');
  @override
  late final GeneratedColumn<String> smsBody = GeneratedColumn<String>(
      'sms_body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailSubjectMeta =
      const VerificationMeta('emailSubject');
  @override
  late final GeneratedColumn<String> emailSubject = GeneratedColumn<String>(
      'email_subject', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailBodyMeta =
      const VerificationMeta('emailBody');
  @override
  late final GeneratedColumn<String> emailBody = GeneratedColumn<String>(
      'email_body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        templateKey,
        smsBody,
        emailSubject,
        emailBody,
        active,
        createdAt,
        updatedAt,
        needsSync,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_message_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalMessageTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('template_key')) {
      context.handle(
          _templateKeyMeta,
          templateKey.isAcceptableOrUnknown(
              data['template_key']!, _templateKeyMeta));
    } else if (isInserting) {
      context.missing(_templateKeyMeta);
    }
    if (data.containsKey('sms_body')) {
      context.handle(_smsBodyMeta,
          smsBody.isAcceptableOrUnknown(data['sms_body']!, _smsBodyMeta));
    } else if (isInserting) {
      context.missing(_smsBodyMeta);
    }
    if (data.containsKey('email_subject')) {
      context.handle(
          _emailSubjectMeta,
          emailSubject.isAcceptableOrUnknown(
              data['email_subject']!, _emailSubjectMeta));
    }
    if (data.containsKey('email_body')) {
      context.handle(_emailBodyMeta,
          emailBody.isAcceptableOrUnknown(data['email_body']!, _emailBodyMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMessageTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessageTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      templateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_key'])!,
      smsBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sms_body'])!,
      emailSubject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_subject']),
      emailBody: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email_body']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalMessageTemplatesTable createAlias(String alias) {
    return $LocalMessageTemplatesTable(attachedDatabase, alias);
  }
}

class LocalMessageTemplate extends DataClass
    implements Insertable<LocalMessageTemplate> {
  final String id;
  final String organizationId;
  final String templateKey;
  final String smsBody;
  final String? emailSubject;
  final String? emailBody;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;
  final DateTime? lastSyncedAt;
  const LocalMessageTemplate(
      {required this.id,
      required this.organizationId,
      required this.templateKey,
      required this.smsBody,
      this.emailSubject,
      this.emailBody,
      required this.active,
      required this.createdAt,
      required this.updatedAt,
      required this.needsSync,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['template_key'] = Variable<String>(templateKey);
    map['sms_body'] = Variable<String>(smsBody);
    if (!nullToAbsent || emailSubject != null) {
      map['email_subject'] = Variable<String>(emailSubject);
    }
    if (!nullToAbsent || emailBody != null) {
      map['email_body'] = Variable<String>(emailBody);
    }
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalMessageTemplatesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessageTemplatesCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      templateKey: Value(templateKey),
      smsBody: Value(smsBody),
      emailSubject: emailSubject == null && nullToAbsent
          ? const Value.absent()
          : Value(emailSubject),
      emailBody: emailBody == null && nullToAbsent
          ? const Value.absent()
          : Value(emailBody),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      needsSync: Value(needsSync),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalMessageTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessageTemplate(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      smsBody: serializer.fromJson<String>(json['smsBody']),
      emailSubject: serializer.fromJson<String?>(json['emailSubject']),
      emailBody: serializer.fromJson<String?>(json['emailBody']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'templateKey': serializer.toJson<String>(templateKey),
      'smsBody': serializer.toJson<String>(smsBody),
      'emailSubject': serializer.toJson<String?>(emailSubject),
      'emailBody': serializer.toJson<String?>(emailBody),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalMessageTemplate copyWith(
          {String? id,
          String? organizationId,
          String? templateKey,
          String? smsBody,
          Value<String?> emailSubject = const Value.absent(),
          Value<String?> emailBody = const Value.absent(),
          bool? active,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? needsSync,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalMessageTemplate(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        templateKey: templateKey ?? this.templateKey,
        smsBody: smsBody ?? this.smsBody,
        emailSubject:
            emailSubject.present ? emailSubject.value : this.emailSubject,
        emailBody: emailBody.present ? emailBody.value : this.emailBody,
        active: active ?? this.active,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        needsSync: needsSync ?? this.needsSync,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalMessageTemplate copyWithCompanion(LocalMessageTemplatesCompanion data) {
    return LocalMessageTemplate(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      templateKey:
          data.templateKey.present ? data.templateKey.value : this.templateKey,
      smsBody: data.smsBody.present ? data.smsBody.value : this.smsBody,
      emailSubject: data.emailSubject.present
          ? data.emailSubject.value
          : this.emailSubject,
      emailBody: data.emailBody.present ? data.emailBody.value : this.emailBody,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessageTemplate(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('templateKey: $templateKey, ')
          ..write('smsBody: $smsBody, ')
          ..write('emailSubject: $emailSubject, ')
          ..write('emailBody: $emailBody, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      organizationId,
      templateKey,
      smsBody,
      emailSubject,
      emailBody,
      active,
      createdAt,
      updatedAt,
      needsSync,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessageTemplate &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.templateKey == this.templateKey &&
          other.smsBody == this.smsBody &&
          other.emailSubject == this.emailSubject &&
          other.emailBody == this.emailBody &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.needsSync == this.needsSync &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalMessageTemplatesCompanion
    extends UpdateCompanion<LocalMessageTemplate> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> templateKey;
  final Value<String> smsBody;
  final Value<String?> emailSubject;
  final Value<String?> emailBody;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> needsSync;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalMessageTemplatesCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.smsBody = const Value.absent(),
    this.emailSubject = const Value.absent(),
    this.emailBody = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMessageTemplatesCompanion.insert({
    required String id,
    required String organizationId,
    required String templateKey,
    required String smsBody,
    this.emailSubject = const Value.absent(),
    this.emailBody = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        templateKey = Value(templateKey),
        smsBody = Value(smsBody);
  static Insertable<LocalMessageTemplate> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? templateKey,
    Expression<String>? smsBody,
    Expression<String>? emailSubject,
    Expression<String>? emailBody,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? needsSync,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (templateKey != null) 'template_key': templateKey,
      if (smsBody != null) 'sms_body': smsBody,
      if (emailSubject != null) 'email_subject': emailSubject,
      if (emailBody != null) 'email_body': emailBody,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMessageTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String>? templateKey,
      Value<String>? smsBody,
      Value<String?>? emailSubject,
      Value<String?>? emailBody,
      Value<bool>? active,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? needsSync,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalMessageTemplatesCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      templateKey: templateKey ?? this.templateKey,
      smsBody: smsBody ?? this.smsBody,
      emailSubject: emailSubject ?? this.emailSubject,
      emailBody: emailBody ?? this.emailBody,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (smsBody.present) {
      map['sms_body'] = Variable<String>(smsBody.value);
    }
    if (emailSubject.present) {
      map['email_subject'] = Variable<String>(emailSubject.value);
    }
    if (emailBody.present) {
      map['email_body'] = Variable<String>(emailBody.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessageTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('templateKey: $templateKey, ')
          ..write('smsBody: $smsBody, ')
          ..write('emailSubject: $emailSubject, ')
          ..write('emailBody: $emailBody, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalOrganizationsTable extends LocalOrganizations
    with TableInfo<$LocalOrganizationsTable, LocalOrganization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalOrganizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('America/New_York'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, timezone, createdAt, updatedAt, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_organizations';
  @override
  VerificationContext validateIntegrity(Insertable<LocalOrganization> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalOrganization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalOrganization(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalOrganizationsTable createAlias(String alias) {
    return $LocalOrganizationsTable(attachedDatabase, alias);
  }
}

class LocalOrganization extends DataClass
    implements Insertable<LocalOrganization> {
  final String id;
  final String name;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const LocalOrganization(
      {required this.id,
      required this.name,
      required this.timezone,
      required this.createdAt,
      required this.updatedAt,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['timezone'] = Variable<String>(timezone);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalOrganizationsCompanion toCompanion(bool nullToAbsent) {
    return LocalOrganizationsCompanion(
      id: Value(id),
      name: Value(name),
      timezone: Value(timezone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalOrganization.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalOrganization(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'timezone': serializer.toJson<String>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalOrganization copyWith(
          {String? id,
          String? name,
          String? timezone,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalOrganization(
        id: id ?? this.id,
        name: name ?? this.name,
        timezone: timezone ?? this.timezone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalOrganization copyWithCompanion(LocalOrganizationsCompanion data) {
    return LocalOrganization(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrganization(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, timezone, createdAt, updatedAt, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalOrganization &&
          other.id == this.id &&
          other.name == this.name &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalOrganizationsCompanion extends UpdateCompanion<LocalOrganization> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> timezone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalOrganizationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalOrganizationsCompanion.insert({
    required String id,
    required String name,
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<LocalOrganization> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalOrganizationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? timezone,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalOrganizationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalOrganizationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalProfilesTable extends LocalProfiles
    with TableInfo<$LocalProfilesTable, LocalProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _organizationIdMeta =
      const VerificationMeta('organizationId');
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
      'organization_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authUserIdMeta =
      const VerificationMeta('authUserId');
  @override
  late final GeneratedColumn<String> authUserId = GeneratedColumn<String>(
      'auth_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('owner'));
  static const VerificationMeta _phoneE164Meta =
      const VerificationMeta('phoneE164');
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
      'phone_e164', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        organizationId,
        authUserId,
        fullName,
        role,
        phoneE164,
        createdAt,
        updatedAt,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<LocalProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
          _organizationIdMeta,
          organizationId.isAcceptableOrUnknown(
              data['organization_id']!, _organizationIdMeta));
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('auth_user_id')) {
      context.handle(
          _authUserIdMeta,
          authUserId.isAcceptableOrUnknown(
              data['auth_user_id']!, _authUserIdMeta));
    } else if (isInserting) {
      context.missing(_authUserIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('phone_e164')) {
      context.handle(_phoneE164Meta,
          phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      organizationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}organization_id'])!,
      authUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auth_user_id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      phoneE164: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_e164']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $LocalProfilesTable createAlias(String alias) {
    return $LocalProfilesTable(attachedDatabase, alias);
  }
}

class LocalProfile extends DataClass implements Insertable<LocalProfile> {
  final String id;
  final String organizationId;
  final String authUserId;
  final String fullName;
  final String role;
  final String? phoneE164;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncedAt;
  const LocalProfile(
      {required this.id,
      required this.organizationId,
      required this.authUserId,
      required this.fullName,
      required this.role,
      this.phoneE164,
      required this.createdAt,
      required this.updatedAt,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['auth_user_id'] = Variable<String>(authUserId);
    map['full_name'] = Variable<String>(fullName);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || phoneE164 != null) {
      map['phone_e164'] = Variable<String>(phoneE164);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocalProfilesCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      authUserId: Value(authUserId),
      fullName: Value(fullName),
      role: Value(role),
      phoneE164: phoneE164 == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneE164),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalProfile(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      authUserId: serializer.fromJson<String>(json['authUserId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      role: serializer.fromJson<String>(json['role']),
      phoneE164: serializer.fromJson<String?>(json['phoneE164']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'authUserId': serializer.toJson<String>(authUserId),
      'fullName': serializer.toJson<String>(fullName),
      'role': serializer.toJson<String>(role),
      'phoneE164': serializer.toJson<String?>(phoneE164),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalProfile copyWith(
          {String? id,
          String? organizationId,
          String? authUserId,
          String? fullName,
          String? role,
          Value<String?> phoneE164 = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      LocalProfile(
        id: id ?? this.id,
        organizationId: organizationId ?? this.organizationId,
        authUserId: authUserId ?? this.authUserId,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        phoneE164: phoneE164.present ? phoneE164.value : this.phoneE164,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  LocalProfile copyWithCompanion(LocalProfilesCompanion data) {
    return LocalProfile(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      authUserId:
          data.authUserId.present ? data.authUserId.value : this.authUserId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      role: data.role.present ? data.role.value : this.role,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfile(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('authUserId: $authUserId, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, organizationId, authUserId, fullName,
      role, phoneE164, createdAt, updatedAt, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalProfile &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.authUserId == this.authUserId &&
          other.fullName == this.fullName &&
          other.role == this.role &&
          other.phoneE164 == this.phoneE164 &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalProfilesCompanion extends UpdateCompanion<LocalProfile> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> authUserId;
  final Value<String> fullName;
  final Value<String> role;
  final Value<String?> phoneE164;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const LocalProfilesCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.authUserId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.role = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalProfilesCompanion.insert({
    required String id,
    required String organizationId,
    required String authUserId,
    required String fullName,
    this.role = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        organizationId = Value(organizationId),
        authUserId = Value(authUserId),
        fullName = Value(fullName);
  static Insertable<LocalProfile> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? authUserId,
    Expression<String>? fullName,
    Expression<String>? role,
    Expression<String>? phoneE164,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (authUserId != null) 'auth_user_id': authUserId,
      if (fullName != null) 'full_name': fullName,
      if (role != null) 'role': role,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? organizationId,
      Value<String>? authUserId,
      Value<String>? fullName,
      Value<String>? role,
      Value<String?>? phoneE164,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return LocalProfilesCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneE164: phoneE164 ?? this.phoneE164,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (authUserId.present) {
      map['auth_user_id'] = Variable<String>(authUserId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalProfilesCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('authUserId: $authUserId, ')
          ..write('fullName: $fullName, ')
          ..write('role: $role, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncActionsTable extends PendingSyncActions
    with TableInfo<$PendingSyncActionsTable, PendingSyncAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientMutationIdMeta =
      const VerificationMeta('clientMutationId');
  @override
  late final GeneratedColumn<String> clientMutationId = GeneratedColumn<String>(
      'client_mutation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mutationTypeMeta =
      const VerificationMeta('mutationType');
  @override
  late final GeneratedColumn<String> mutationType = GeneratedColumn<String>(
      'mutation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _baseVersionMeta =
      const VerificationMeta('baseVersion');
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
      'base_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        clientMutationId,
        entityType,
        entityId,
        mutationType,
        baseVersion,
        payload,
        retryCount,
        createdAt,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync_actions';
  @override
  VerificationContext validateIntegrity(Insertable<PendingSyncAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('client_mutation_id')) {
      context.handle(
          _clientMutationIdMeta,
          clientMutationId.isAcceptableOrUnknown(
              data['client_mutation_id']!, _clientMutationIdMeta));
    } else if (isInserting) {
      context.missing(_clientMutationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    }
    if (data.containsKey('mutation_type')) {
      context.handle(
          _mutationTypeMeta,
          mutationType.isAcceptableOrUnknown(
              data['mutation_type']!, _mutationTypeMeta));
    } else if (isInserting) {
      context.missing(_mutationTypeMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
          _baseVersionMeta,
          baseVersion.isAcceptableOrUnknown(
              data['base_version']!, _baseVersionMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      clientMutationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}client_mutation_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id']),
      mutationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mutation_type'])!,
      baseVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}base_version']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $PendingSyncActionsTable createAlias(String alias) {
    return $PendingSyncActionsTable(attachedDatabase, alias);
  }
}

class PendingSyncAction extends DataClass
    implements Insertable<PendingSyncAction> {
  final String id;
  final String clientMutationId;
  final String entityType;
  final String? entityId;
  final String mutationType;
  final int? baseVersion;
  final String payload;
  final int retryCount;
  final DateTime createdAt;
  final String status;
  const PendingSyncAction(
      {required this.id,
      required this.clientMutationId,
      required this.entityType,
      this.entityId,
      required this.mutationType,
      this.baseVersion,
      required this.payload,
      required this.retryCount,
      required this.createdAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_mutation_id'] = Variable<String>(clientMutationId);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<String>(entityId);
    }
    map['mutation_type'] = Variable<String>(mutationType);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  PendingSyncActionsCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncActionsCompanion(
      id: Value(id),
      clientMutationId: Value(clientMutationId),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      mutationType: Value(mutationType),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
      payload: Value(payload),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory PendingSyncAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncAction(
      id: serializer.fromJson<String>(json['id']),
      clientMutationId: serializer.fromJson<String>(json['clientMutationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String?>(json['entityId']),
      mutationType: serializer.fromJson<String>(json['mutationType']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientMutationId': serializer.toJson<String>(clientMutationId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String?>(entityId),
      'mutationType': serializer.toJson<String>(mutationType),
      'baseVersion': serializer.toJson<int?>(baseVersion),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
    };
  }

  PendingSyncAction copyWith(
          {String? id,
          String? clientMutationId,
          String? entityType,
          Value<String?> entityId = const Value.absent(),
          String? mutationType,
          Value<int?> baseVersion = const Value.absent(),
          String? payload,
          int? retryCount,
          DateTime? createdAt,
          String? status}) =>
      PendingSyncAction(
        id: id ?? this.id,
        clientMutationId: clientMutationId ?? this.clientMutationId,
        entityType: entityType ?? this.entityType,
        entityId: entityId.present ? entityId.value : this.entityId,
        mutationType: mutationType ?? this.mutationType,
        baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
        payload: payload ?? this.payload,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );
  PendingSyncAction copyWithCompanion(PendingSyncActionsCompanion data) {
    return PendingSyncAction(
      id: data.id.present ? data.id.value : this.id,
      clientMutationId: data.clientMutationId.present
          ? data.clientMutationId.value
          : this.clientMutationId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      mutationType: data.mutationType.present
          ? data.mutationType.value
          : this.mutationType,
      baseVersion:
          data.baseVersion.present ? data.baseVersion.value : this.baseVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncAction(')
          ..write('id: $id, ')
          ..write('clientMutationId: $clientMutationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('mutationType: $mutationType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, clientMutationId, entityType, entityId,
      mutationType, baseVersion, payload, retryCount, createdAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncAction &&
          other.id == this.id &&
          other.clientMutationId == this.clientMutationId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.mutationType == this.mutationType &&
          other.baseVersion == this.baseVersion &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class PendingSyncActionsCompanion extends UpdateCompanion<PendingSyncAction> {
  final Value<String> id;
  final Value<String> clientMutationId;
  final Value<String> entityType;
  final Value<String?> entityId;
  final Value<String> mutationType;
  final Value<int?> baseVersion;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<int> rowid;
  const PendingSyncActionsCompanion({
    this.id = const Value.absent(),
    this.clientMutationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.mutationType = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingSyncActionsCompanion.insert({
    required String id,
    required String clientMutationId,
    required String entityType,
    this.entityId = const Value.absent(),
    required String mutationType,
    this.baseVersion = const Value.absent(),
    required String payload,
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        clientMutationId = Value(clientMutationId),
        entityType = Value(entityType),
        mutationType = Value(mutationType),
        payload = Value(payload);
  static Insertable<PendingSyncAction> custom({
    Expression<String>? id,
    Expression<String>? clientMutationId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? mutationType,
    Expression<int>? baseVersion,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientMutationId != null) 'client_mutation_id': clientMutationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (mutationType != null) 'mutation_type': mutationType,
      if (baseVersion != null) 'base_version': baseVersion,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingSyncActionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? clientMutationId,
      Value<String>? entityType,
      Value<String?>? entityId,
      Value<String>? mutationType,
      Value<int?>? baseVersion,
      Value<String>? payload,
      Value<int>? retryCount,
      Value<DateTime>? createdAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return PendingSyncActionsCompanion(
      id: id ?? this.id,
      clientMutationId: clientMutationId ?? this.clientMutationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      mutationType: mutationType ?? this.mutationType,
      baseVersion: baseVersion ?? this.baseVersion,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientMutationId.present) {
      map['client_mutation_id'] = Variable<String>(clientMutationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (mutationType.present) {
      map['mutation_type'] = Variable<String>(mutationType.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncActionsCompanion(')
          ..write('id: $id, ')
          ..write('clientMutationId: $clientMutationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('mutationType: $mutationType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
      'cursor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [entityType, cursor, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta,
          cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      cursor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String entityType;
  final String cursor;
  final DateTime updatedAt;
  const SyncCursor(
      {required this.entityType,
      required this.cursor,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['cursor'] = Variable<String>(cursor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entityType: Value(entityType),
      cursor: Value(cursor),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      entityType: serializer.fromJson<String>(json['entityType']),
      cursor: serializer.fromJson<String>(json['cursor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'cursor': serializer.toJson<String>(cursor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncCursor copyWith(
          {String? entityType, String? cursor, DateTime? updatedAt}) =>
      SyncCursor(
        entityType: entityType ?? this.entityType,
        cursor: cursor ?? this.cursor,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('entityType: $entityType, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, cursor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.entityType == this.entityType &&
          other.cursor == this.cursor &&
          other.updatedAt == this.updatedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> entityType;
  final Value<String> cursor;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entityType = const Value.absent(),
    this.cursor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entityType,
    required String cursor,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : entityType = Value(entityType),
        cursor = Value(cursor);
  static Insertable<SyncCursor> custom({
    Expression<String>? entityType,
    Expression<String>? cursor,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (cursor != null) 'cursor': cursor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith(
      {Value<String>? entityType,
      Value<String>? cursor,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SyncCursorsCompanion(
      entityType: entityType ?? this.entityType,
      cursor: cursor ?? this.cursor,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalLeadsTable localLeads = $LocalLeadsTable(this);
  late final $LocalJobsTable localJobs = $LocalJobsTable(this);
  late final $LocalFollowupSequencesTable localFollowupSequences =
      $LocalFollowupSequencesTable(this);
  late final $LocalFollowupMessagesTable localFollowupMessages =
      $LocalFollowupMessagesTable(this);
  late final $LocalCallLogsTable localCallLogs = $LocalCallLogsTable(this);
  late final $LocalMessageTemplatesTable localMessageTemplates =
      $LocalMessageTemplatesTable(this);
  late final $LocalOrganizationsTable localOrganizations =
      $LocalOrganizationsTable(this);
  late final $LocalProfilesTable localProfiles = $LocalProfilesTable(this);
  late final $PendingSyncActionsTable pendingSyncActions =
      $PendingSyncActionsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final LeadsDao leadsDao = LeadsDao(this as AppDatabase);
  late final JobsDao jobsDao = JobsDao(this as AppDatabase);
  late final FollowupsDao followupsDao = FollowupsDao(this as AppDatabase);
  late final CallLogsDao callLogsDao = CallLogsDao(this as AppDatabase);
  late final TemplatesDao templatesDao = TemplatesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localLeads,
        localJobs,
        localFollowupSequences,
        localFollowupMessages,
        localCallLogs,
        localMessageTemplates,
        localOrganizations,
        localProfiles,
        pendingSyncActions,
        syncCursors
      ];
}

typedef $$LocalLeadsTableCreateCompanionBuilder = LocalLeadsCompanion Function({
  required String id,
  required String organizationId,
  Value<String?> createdByProfileId,
  required String clientName,
  Value<String?> phoneE164,
  Value<String?> email,
  required String jobType,
  Value<String?> notes,
  Value<String> status,
  Value<String> followupState,
  Value<DateTime?> estimateSentAt,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalLeadsTableUpdateCompanionBuilder = LocalLeadsCompanion Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String?> createdByProfileId,
  Value<String> clientName,
  Value<String?> phoneE164,
  Value<String?> email,
  Value<String> jobType,
  Value<String?> notes,
  Value<String> status,
  Value<String> followupState,
  Value<DateTime?> estimateSentAt,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalLeadsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalLeadsTable> {
  $$LocalLeadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdByProfileId => $composableBuilder(
      column: $table.createdByProfileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get followupState => $composableBuilder(
      column: $table.followupState, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get estimateSentAt => $composableBuilder(
      column: $table.estimateSentAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalLeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalLeadsTable> {
  $$LocalLeadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdByProfileId => $composableBuilder(
      column: $table.createdByProfileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get followupState => $composableBuilder(
      column: $table.followupState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get estimateSentAt => $composableBuilder(
      column: $table.estimateSentAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalLeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalLeadsTable> {
  $$LocalLeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get createdByProfileId => $composableBuilder(
      column: $table.createdByProfileId, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get followupState => $composableBuilder(
      column: $table.followupState, builder: (column) => column);

  GeneratedColumn<DateTime> get estimateSentAt => $composableBuilder(
      column: $table.estimateSentAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalLeadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalLeadsTable,
    LocalLead,
    $$LocalLeadsTableFilterComposer,
    $$LocalLeadsTableOrderingComposer,
    $$LocalLeadsTableAnnotationComposer,
    $$LocalLeadsTableCreateCompanionBuilder,
    $$LocalLeadsTableUpdateCompanionBuilder,
    (LocalLead, BaseReferences<_$AppDatabase, $LocalLeadsTable, LocalLead>),
    LocalLead,
    PrefetchHooks Function()> {
  $$LocalLeadsTableTableManager(_$AppDatabase db, $LocalLeadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalLeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalLeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalLeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String?> createdByProfileId = const Value.absent(),
            Value<String> clientName = const Value.absent(),
            Value<String?> phoneE164 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String> jobType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> followupState = const Value.absent(),
            Value<DateTime?> estimateSentAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalLeadsCompanion(
            id: id,
            organizationId: organizationId,
            createdByProfileId: createdByProfileId,
            clientName: clientName,
            phoneE164: phoneE164,
            email: email,
            jobType: jobType,
            notes: notes,
            status: status,
            followupState: followupState,
            estimateSentAt: estimateSentAt,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            Value<String?> createdByProfileId = const Value.absent(),
            required String clientName,
            Value<String?> phoneE164 = const Value.absent(),
            Value<String?> email = const Value.absent(),
            required String jobType,
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> followupState = const Value.absent(),
            Value<DateTime?> estimateSentAt = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalLeadsCompanion.insert(
            id: id,
            organizationId: organizationId,
            createdByProfileId: createdByProfileId,
            clientName: clientName,
            phoneE164: phoneE164,
            email: email,
            jobType: jobType,
            notes: notes,
            status: status,
            followupState: followupState,
            estimateSentAt: estimateSentAt,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalLeadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalLeadsTable,
    LocalLead,
    $$LocalLeadsTableFilterComposer,
    $$LocalLeadsTableOrderingComposer,
    $$LocalLeadsTableAnnotationComposer,
    $$LocalLeadsTableCreateCompanionBuilder,
    $$LocalLeadsTableUpdateCompanionBuilder,
    (LocalLead, BaseReferences<_$AppDatabase, $LocalLeadsTable, LocalLead>),
    LocalLead,
    PrefetchHooks Function()>;
typedef $$LocalJobsTableCreateCompanionBuilder = LocalJobsCompanion Function({
  required String id,
  required String organizationId,
  Value<String?> leadId,
  required String clientName,
  required String jobType,
  Value<String> phase,
  Value<String> healthStatus,
  Value<DateTime?> estimatedCompletionDate,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalJobsTableUpdateCompanionBuilder = LocalJobsCompanion Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String?> leadId,
  Value<String> clientName,
  Value<String> jobType,
  Value<String> phase,
  Value<String> healthStatus,
  Value<DateTime?> estimatedCompletionDate,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalJobsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalJobsTable> {
  $$LocalJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phase => $composableBuilder(
      column: $table.phase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get estimatedCompletionDate => $composableBuilder(
      column: $table.estimatedCompletionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalJobsTable> {
  $$LocalJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jobType => $composableBuilder(
      column: $table.jobType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phase => $composableBuilder(
      column: $table.phase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get estimatedCompletionDate => $composableBuilder(
      column: $table.estimatedCompletionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalJobsTable> {
  $$LocalJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get clientName => $composableBuilder(
      column: $table.clientName, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  GeneratedColumn<String> get healthStatus => $composableBuilder(
      column: $table.healthStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get estimatedCompletionDate => $composableBuilder(
      column: $table.estimatedCompletionDate, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalJobsTable,
    LocalJob,
    $$LocalJobsTableFilterComposer,
    $$LocalJobsTableOrderingComposer,
    $$LocalJobsTableAnnotationComposer,
    $$LocalJobsTableCreateCompanionBuilder,
    $$LocalJobsTableUpdateCompanionBuilder,
    (LocalJob, BaseReferences<_$AppDatabase, $LocalJobsTable, LocalJob>),
    LocalJob,
    PrefetchHooks Function()> {
  $$LocalJobsTableTableManager(_$AppDatabase db, $LocalJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String?> leadId = const Value.absent(),
            Value<String> clientName = const Value.absent(),
            Value<String> jobType = const Value.absent(),
            Value<String> phase = const Value.absent(),
            Value<String> healthStatus = const Value.absent(),
            Value<DateTime?> estimatedCompletionDate = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalJobsCompanion(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            clientName: clientName,
            jobType: jobType,
            phase: phase,
            healthStatus: healthStatus,
            estimatedCompletionDate: estimatedCompletionDate,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            Value<String?> leadId = const Value.absent(),
            required String clientName,
            required String jobType,
            Value<String> phase = const Value.absent(),
            Value<String> healthStatus = const Value.absent(),
            Value<DateTime?> estimatedCompletionDate = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalJobsCompanion.insert(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            clientName: clientName,
            jobType: jobType,
            phase: phase,
            healthStatus: healthStatus,
            estimatedCompletionDate: estimatedCompletionDate,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalJobsTable,
    LocalJob,
    $$LocalJobsTableFilterComposer,
    $$LocalJobsTableOrderingComposer,
    $$LocalJobsTableAnnotationComposer,
    $$LocalJobsTableCreateCompanionBuilder,
    $$LocalJobsTableUpdateCompanionBuilder,
    (LocalJob, BaseReferences<_$AppDatabase, $LocalJobsTable, LocalJob>),
    LocalJob,
    PrefetchHooks Function()>;
typedef $$LocalFollowupSequencesTableCreateCompanionBuilder
    = LocalFollowupSequencesCompanion Function({
  required String id,
  required String organizationId,
  required String leadId,
  Value<String> state,
  required DateTime startDateLocal,
  required String timezone,
  Value<DateTime?> nextSendAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> stoppedAt,
  Value<DateTime?> completedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalFollowupSequencesTableUpdateCompanionBuilder
    = LocalFollowupSequencesCompanion Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String> leadId,
  Value<String> state,
  Value<DateTime> startDateLocal,
  Value<String> timezone,
  Value<DateTime?> nextSendAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> pausedAt,
  Value<DateTime?> stoppedAt,
  Value<DateTime?> completedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalFollowupSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFollowupSequencesTable> {
  $$LocalFollowupSequencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDateLocal => $composableBuilder(
      column: $table.startDateLocal,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextSendAt => $composableBuilder(
      column: $table.nextSendAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get stoppedAt => $composableBuilder(
      column: $table.stoppedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalFollowupSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFollowupSequencesTable> {
  $$LocalFollowupSequencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get state => $composableBuilder(
      column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDateLocal => $composableBuilder(
      column: $table.startDateLocal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextSendAt => $composableBuilder(
      column: $table.nextSendAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
      column: $table.pausedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get stoppedAt => $composableBuilder(
      column: $table.stoppedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalFollowupSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFollowupSequencesTable> {
  $$LocalFollowupSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get startDateLocal => $composableBuilder(
      column: $table.startDateLocal, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get nextSendAt => $composableBuilder(
      column: $table.nextSendAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get stoppedAt =>
      $composableBuilder(column: $table.stoppedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalFollowupSequencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalFollowupSequencesTable,
    LocalFollowupSequence,
    $$LocalFollowupSequencesTableFilterComposer,
    $$LocalFollowupSequencesTableOrderingComposer,
    $$LocalFollowupSequencesTableAnnotationComposer,
    $$LocalFollowupSequencesTableCreateCompanionBuilder,
    $$LocalFollowupSequencesTableUpdateCompanionBuilder,
    (
      LocalFollowupSequence,
      BaseReferences<_$AppDatabase, $LocalFollowupSequencesTable,
          LocalFollowupSequence>
    ),
    LocalFollowupSequence,
    PrefetchHooks Function()> {
  $$LocalFollowupSequencesTableTableManager(
      _$AppDatabase db, $LocalFollowupSequencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFollowupSequencesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFollowupSequencesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFollowupSequencesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String> leadId = const Value.absent(),
            Value<String> state = const Value.absent(),
            Value<DateTime> startDateLocal = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime?> nextSendAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> stoppedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFollowupSequencesCompanion(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            state: state,
            startDateLocal: startDateLocal,
            timezone: timezone,
            nextSendAt: nextSendAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pausedAt: pausedAt,
            stoppedAt: stoppedAt,
            completedAt: completedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            required String leadId,
            Value<String> state = const Value.absent(),
            required DateTime startDateLocal,
            required String timezone,
            Value<DateTime?> nextSendAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> pausedAt = const Value.absent(),
            Value<DateTime?> stoppedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFollowupSequencesCompanion.insert(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            state: state,
            startDateLocal: startDateLocal,
            timezone: timezone,
            nextSendAt: nextSendAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pausedAt: pausedAt,
            stoppedAt: stoppedAt,
            completedAt: completedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFollowupSequencesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalFollowupSequencesTable,
        LocalFollowupSequence,
        $$LocalFollowupSequencesTableFilterComposer,
        $$LocalFollowupSequencesTableOrderingComposer,
        $$LocalFollowupSequencesTableAnnotationComposer,
        $$LocalFollowupSequencesTableCreateCompanionBuilder,
        $$LocalFollowupSequencesTableUpdateCompanionBuilder,
        (
          LocalFollowupSequence,
          BaseReferences<_$AppDatabase, $LocalFollowupSequencesTable,
              LocalFollowupSequence>
        ),
        LocalFollowupSequence,
        PrefetchHooks Function()>;
typedef $$LocalFollowupMessagesTableCreateCompanionBuilder
    = LocalFollowupMessagesCompanion Function({
  required String id,
  required String sequenceId,
  required int stepNumber,
  required String channel,
  required String templateKey,
  required DateTime scheduledAt,
  Value<DateTime?> sentAt,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> providerMessageId,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalFollowupMessagesTableUpdateCompanionBuilder
    = LocalFollowupMessagesCompanion Function({
  Value<String> id,
  Value<String> sequenceId,
  Value<int> stepNumber,
  Value<String> channel,
  Value<String> templateKey,
  Value<DateTime> scheduledAt,
  Value<DateTime?> sentAt,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> providerMessageId,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalFollowupMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFollowupMessagesTable> {
  $$LocalFollowupMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sequenceId => $composableBuilder(
      column: $table.sequenceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stepNumber => $composableBuilder(
      column: $table.stepNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerMessageId => $composableBuilder(
      column: $table.providerMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalFollowupMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFollowupMessagesTable> {
  $$LocalFollowupMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sequenceId => $composableBuilder(
      column: $table.sequenceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stepNumber => $composableBuilder(
      column: $table.stepNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get channel => $composableBuilder(
      column: $table.channel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerMessageId => $composableBuilder(
      column: $table.providerMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalFollowupMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFollowupMessagesTable> {
  $$LocalFollowupMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sequenceId => $composableBuilder(
      column: $table.sequenceId, builder: (column) => column);

  GeneratedColumn<int> get stepNumber => $composableBuilder(
      column: $table.stepNumber, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get providerMessageId => $composableBuilder(
      column: $table.providerMessageId, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalFollowupMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalFollowupMessagesTable,
    LocalFollowupMessage,
    $$LocalFollowupMessagesTableFilterComposer,
    $$LocalFollowupMessagesTableOrderingComposer,
    $$LocalFollowupMessagesTableAnnotationComposer,
    $$LocalFollowupMessagesTableCreateCompanionBuilder,
    $$LocalFollowupMessagesTableUpdateCompanionBuilder,
    (
      LocalFollowupMessage,
      BaseReferences<_$AppDatabase, $LocalFollowupMessagesTable,
          LocalFollowupMessage>
    ),
    LocalFollowupMessage,
    PrefetchHooks Function()> {
  $$LocalFollowupMessagesTableTableManager(
      _$AppDatabase db, $LocalFollowupMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFollowupMessagesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFollowupMessagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFollowupMessagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sequenceId = const Value.absent(),
            Value<int> stepNumber = const Value.absent(),
            Value<String> channel = const Value.absent(),
            Value<String> templateKey = const Value.absent(),
            Value<DateTime> scheduledAt = const Value.absent(),
            Value<DateTime?> sentAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> providerMessageId = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFollowupMessagesCompanion(
            id: id,
            sequenceId: sequenceId,
            stepNumber: stepNumber,
            channel: channel,
            templateKey: templateKey,
            scheduledAt: scheduledAt,
            sentAt: sentAt,
            status: status,
            retryCount: retryCount,
            providerMessageId: providerMessageId,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sequenceId,
            required int stepNumber,
            required String channel,
            required String templateKey,
            required DateTime scheduledAt,
            Value<DateTime?> sentAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> providerMessageId = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFollowupMessagesCompanion.insert(
            id: id,
            sequenceId: sequenceId,
            stepNumber: stepNumber,
            channel: channel,
            templateKey: templateKey,
            scheduledAt: scheduledAt,
            sentAt: sentAt,
            status: status,
            retryCount: retryCount,
            providerMessageId: providerMessageId,
            errorMessage: errorMessage,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFollowupMessagesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalFollowupMessagesTable,
        LocalFollowupMessage,
        $$LocalFollowupMessagesTableFilterComposer,
        $$LocalFollowupMessagesTableOrderingComposer,
        $$LocalFollowupMessagesTableAnnotationComposer,
        $$LocalFollowupMessagesTableCreateCompanionBuilder,
        $$LocalFollowupMessagesTableUpdateCompanionBuilder,
        (
          LocalFollowupMessage,
          BaseReferences<_$AppDatabase, $LocalFollowupMessagesTable,
              LocalFollowupMessage>
        ),
        LocalFollowupMessage,
        PrefetchHooks Function()>;
typedef $$LocalCallLogsTableCreateCompanionBuilder = LocalCallLogsCompanion
    Function({
  required String id,
  required String organizationId,
  Value<String?> leadId,
  required String phoneE164,
  required String platform,
  required String source,
  required DateTime startedAt,
  Value<int> durationSec,
  Value<String> disposition,
  Value<DateTime> createdAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalCallLogsTableUpdateCompanionBuilder = LocalCallLogsCompanion
    Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String?> leadId,
  Value<String> phoneE164,
  Value<String> platform,
  Value<String> source,
  Value<DateTime> startedAt,
  Value<int> durationSec,
  Value<String> disposition,
  Value<DateTime> createdAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalCallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCallLogsTable> {
  $$LocalCallLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalCallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCallLogsTable> {
  $$LocalCallLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get leadId => $composableBuilder(
      column: $table.leadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalCallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCallLogsTable> {
  $$LocalCallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get leadId =>
      $composableBuilder(column: $table.leadId, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSec => $composableBuilder(
      column: $table.durationSec, builder: (column) => column);

  GeneratedColumn<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalCallLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalCallLogsTable,
    LocalCallLog,
    $$LocalCallLogsTableFilterComposer,
    $$LocalCallLogsTableOrderingComposer,
    $$LocalCallLogsTableAnnotationComposer,
    $$LocalCallLogsTableCreateCompanionBuilder,
    $$LocalCallLogsTableUpdateCompanionBuilder,
    (
      LocalCallLog,
      BaseReferences<_$AppDatabase, $LocalCallLogsTable, LocalCallLog>
    ),
    LocalCallLog,
    PrefetchHooks Function()> {
  $$LocalCallLogsTableTableManager(_$AppDatabase db, $LocalCallLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String?> leadId = const Value.absent(),
            Value<String> phoneE164 = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<int> durationSec = const Value.absent(),
            Value<String> disposition = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCallLogsCompanion(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            phoneE164: phoneE164,
            platform: platform,
            source: source,
            startedAt: startedAt,
            durationSec: durationSec,
            disposition: disposition,
            createdAt: createdAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            Value<String?> leadId = const Value.absent(),
            required String phoneE164,
            required String platform,
            required String source,
            required DateTime startedAt,
            Value<int> durationSec = const Value.absent(),
            Value<String> disposition = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalCallLogsCompanion.insert(
            id: id,
            organizationId: organizationId,
            leadId: leadId,
            phoneE164: phoneE164,
            platform: platform,
            source: source,
            startedAt: startedAt,
            durationSec: durationSec,
            disposition: disposition,
            createdAt: createdAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalCallLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalCallLogsTable,
    LocalCallLog,
    $$LocalCallLogsTableFilterComposer,
    $$LocalCallLogsTableOrderingComposer,
    $$LocalCallLogsTableAnnotationComposer,
    $$LocalCallLogsTableCreateCompanionBuilder,
    $$LocalCallLogsTableUpdateCompanionBuilder,
    (
      LocalCallLog,
      BaseReferences<_$AppDatabase, $LocalCallLogsTable, LocalCallLog>
    ),
    LocalCallLog,
    PrefetchHooks Function()>;
typedef $$LocalMessageTemplatesTableCreateCompanionBuilder
    = LocalMessageTemplatesCompanion Function({
  required String id,
  required String organizationId,
  required String templateKey,
  required String smsBody,
  Value<String?> emailSubject,
  Value<String?> emailBody,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalMessageTemplatesTableUpdateCompanionBuilder
    = LocalMessageTemplatesCompanion Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String> templateKey,
  Value<String> smsBody,
  Value<String?> emailSubject,
  Value<String?> emailBody,
  Value<bool> active,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> needsSync,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalMessageTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessageTemplatesTable> {
  $$LocalMessageTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get smsBody => $composableBuilder(
      column: $table.smsBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailSubject => $composableBuilder(
      column: $table.emailSubject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emailBody => $composableBuilder(
      column: $table.emailBody, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMessageTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessageTemplatesTable> {
  $$LocalMessageTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get smsBody => $composableBuilder(
      column: $table.smsBody, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailSubject => $composableBuilder(
      column: $table.emailSubject,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emailBody => $composableBuilder(
      column: $table.emailBody, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalMessageTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessageTemplatesTable> {
  $$LocalMessageTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => column);

  GeneratedColumn<String> get smsBody =>
      $composableBuilder(column: $table.smsBody, builder: (column) => column);

  GeneratedColumn<String> get emailSubject => $composableBuilder(
      column: $table.emailSubject, builder: (column) => column);

  GeneratedColumn<String> get emailBody =>
      $composableBuilder(column: $table.emailBody, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalMessageTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMessageTemplatesTable,
    LocalMessageTemplate,
    $$LocalMessageTemplatesTableFilterComposer,
    $$LocalMessageTemplatesTableOrderingComposer,
    $$LocalMessageTemplatesTableAnnotationComposer,
    $$LocalMessageTemplatesTableCreateCompanionBuilder,
    $$LocalMessageTemplatesTableUpdateCompanionBuilder,
    (
      LocalMessageTemplate,
      BaseReferences<_$AppDatabase, $LocalMessageTemplatesTable,
          LocalMessageTemplate>
    ),
    LocalMessageTemplate,
    PrefetchHooks Function()> {
  $$LocalMessageTemplatesTableTableManager(
      _$AppDatabase db, $LocalMessageTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessageTemplatesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessageTemplatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessageTemplatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String> templateKey = const Value.absent(),
            Value<String> smsBody = const Value.absent(),
            Value<String?> emailSubject = const Value.absent(),
            Value<String?> emailBody = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMessageTemplatesCompanion(
            id: id,
            organizationId: organizationId,
            templateKey: templateKey,
            smsBody: smsBody,
            emailSubject: emailSubject,
            emailBody: emailBody,
            active: active,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            required String templateKey,
            required String smsBody,
            Value<String?> emailSubject = const Value.absent(),
            Value<String?> emailBody = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMessageTemplatesCompanion.insert(
            id: id,
            organizationId: organizationId,
            templateKey: templateKey,
            smsBody: smsBody,
            emailSubject: emailSubject,
            emailBody: emailBody,
            active: active,
            createdAt: createdAt,
            updatedAt: updatedAt,
            needsSync: needsSync,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMessageTemplatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalMessageTemplatesTable,
        LocalMessageTemplate,
        $$LocalMessageTemplatesTableFilterComposer,
        $$LocalMessageTemplatesTableOrderingComposer,
        $$LocalMessageTemplatesTableAnnotationComposer,
        $$LocalMessageTemplatesTableCreateCompanionBuilder,
        $$LocalMessageTemplatesTableUpdateCompanionBuilder,
        (
          LocalMessageTemplate,
          BaseReferences<_$AppDatabase, $LocalMessageTemplatesTable,
              LocalMessageTemplate>
        ),
        LocalMessageTemplate,
        PrefetchHooks Function()>;
typedef $$LocalOrganizationsTableCreateCompanionBuilder
    = LocalOrganizationsCompanion Function({
  required String id,
  required String name,
  Value<String> timezone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalOrganizationsTableUpdateCompanionBuilder
    = LocalOrganizationsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> timezone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalOrganizationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalOrganizationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalOrganizationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalOrganizationsTable> {
  $$LocalOrganizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalOrganizationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalOrganizationsTable,
    LocalOrganization,
    $$LocalOrganizationsTableFilterComposer,
    $$LocalOrganizationsTableOrderingComposer,
    $$LocalOrganizationsTableAnnotationComposer,
    $$LocalOrganizationsTableCreateCompanionBuilder,
    $$LocalOrganizationsTableUpdateCompanionBuilder,
    (
      LocalOrganization,
      BaseReferences<_$AppDatabase, $LocalOrganizationsTable, LocalOrganization>
    ),
    LocalOrganization,
    PrefetchHooks Function()> {
  $$LocalOrganizationsTableTableManager(
      _$AppDatabase db, $LocalOrganizationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalOrganizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalOrganizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalOrganizationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalOrganizationsCompanion(
            id: id,
            name: name,
            timezone: timezone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> timezone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalOrganizationsCompanion.insert(
            id: id,
            name: name,
            timezone: timezone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalOrganizationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalOrganizationsTable,
    LocalOrganization,
    $$LocalOrganizationsTableFilterComposer,
    $$LocalOrganizationsTableOrderingComposer,
    $$LocalOrganizationsTableAnnotationComposer,
    $$LocalOrganizationsTableCreateCompanionBuilder,
    $$LocalOrganizationsTableUpdateCompanionBuilder,
    (
      LocalOrganization,
      BaseReferences<_$AppDatabase, $LocalOrganizationsTable, LocalOrganization>
    ),
    LocalOrganization,
    PrefetchHooks Function()>;
typedef $$LocalProfilesTableCreateCompanionBuilder = LocalProfilesCompanion
    Function({
  required String id,
  required String organizationId,
  required String authUserId,
  required String fullName,
  Value<String> role,
  Value<String?> phoneE164,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$LocalProfilesTableUpdateCompanionBuilder = LocalProfilesCompanion
    Function({
  Value<String> id,
  Value<String> organizationId,
  Value<String> authUserId,
  Value<String> fullName,
  Value<String> role,
  Value<String?> phoneE164,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$LocalProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organizationId => $composableBuilder(
      column: $table.organizationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
      column: $table.phoneE164, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalProfilesTable> {
  $$LocalProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
      column: $table.organizationId, builder: (column) => column);

  GeneratedColumn<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$LocalProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalProfilesTable,
    LocalProfile,
    $$LocalProfilesTableFilterComposer,
    $$LocalProfilesTableOrderingComposer,
    $$LocalProfilesTableAnnotationComposer,
    $$LocalProfilesTableCreateCompanionBuilder,
    $$LocalProfilesTableUpdateCompanionBuilder,
    (
      LocalProfile,
      BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>
    ),
    LocalProfile,
    PrefetchHooks Function()> {
  $$LocalProfilesTableTableManager(_$AppDatabase db, $LocalProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> organizationId = const Value.absent(),
            Value<String> authUserId = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> phoneE164 = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProfilesCompanion(
            id: id,
            organizationId: organizationId,
            authUserId: authUserId,
            fullName: fullName,
            role: role,
            phoneE164: phoneE164,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String organizationId,
            required String authUserId,
            required String fullName,
            Value<String> role = const Value.absent(),
            Value<String?> phoneE164 = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalProfilesCompanion.insert(
            id: id,
            organizationId: organizationId,
            authUserId: authUserId,
            fullName: fullName,
            role: role,
            phoneE164: phoneE164,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalProfilesTable,
    LocalProfile,
    $$LocalProfilesTableFilterComposer,
    $$LocalProfilesTableOrderingComposer,
    $$LocalProfilesTableAnnotationComposer,
    $$LocalProfilesTableCreateCompanionBuilder,
    $$LocalProfilesTableUpdateCompanionBuilder,
    (
      LocalProfile,
      BaseReferences<_$AppDatabase, $LocalProfilesTable, LocalProfile>
    ),
    LocalProfile,
    PrefetchHooks Function()>;
typedef $$PendingSyncActionsTableCreateCompanionBuilder
    = PendingSyncActionsCompanion Function({
  required String id,
  required String clientMutationId,
  required String entityType,
  Value<String?> entityId,
  required String mutationType,
  Value<int?> baseVersion,
  required String payload,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$PendingSyncActionsTableUpdateCompanionBuilder
    = PendingSyncActionsCompanion Function({
  Value<String> id,
  Value<String> clientMutationId,
  Value<String> entityType,
  Value<String?> entityId,
  Value<String> mutationType,
  Value<int?> baseVersion,
  Value<String> payload,
  Value<int> retryCount,
  Value<DateTime> createdAt,
  Value<String> status,
  Value<int> rowid,
});

class $$PendingSyncActionsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncActionsTable> {
  $$PendingSyncActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$PendingSyncActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncActionsTable> {
  $$PendingSyncActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mutationType => $composableBuilder(
      column: $table.mutationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$PendingSyncActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncActionsTable> {
  $$PendingSyncActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clientMutationId => $composableBuilder(
      column: $table.clientMutationId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PendingSyncActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingSyncActionsTable,
    PendingSyncAction,
    $$PendingSyncActionsTableFilterComposer,
    $$PendingSyncActionsTableOrderingComposer,
    $$PendingSyncActionsTableAnnotationComposer,
    $$PendingSyncActionsTableCreateCompanionBuilder,
    $$PendingSyncActionsTableUpdateCompanionBuilder,
    (
      PendingSyncAction,
      BaseReferences<_$AppDatabase, $PendingSyncActionsTable, PendingSyncAction>
    ),
    PendingSyncAction,
    PrefetchHooks Function()> {
  $$PendingSyncActionsTableTableManager(
      _$AppDatabase db, $PendingSyncActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncActionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> clientMutationId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String?> entityId = const Value.absent(),
            Value<String> mutationType = const Value.absent(),
            Value<int?> baseVersion = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingSyncActionsCompanion(
            id: id,
            clientMutationId: clientMutationId,
            entityType: entityType,
            entityId: entityId,
            mutationType: mutationType,
            baseVersion: baseVersion,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String clientMutationId,
            required String entityType,
            Value<String?> entityId = const Value.absent(),
            required String mutationType,
            Value<int?> baseVersion = const Value.absent(),
            required String payload,
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PendingSyncActionsCompanion.insert(
            id: id,
            clientMutationId: clientMutationId,
            entityType: entityType,
            entityId: entityId,
            mutationType: mutationType,
            baseVersion: baseVersion,
            payload: payload,
            retryCount: retryCount,
            createdAt: createdAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingSyncActionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingSyncActionsTable,
    PendingSyncAction,
    $$PendingSyncActionsTableFilterComposer,
    $$PendingSyncActionsTableOrderingComposer,
    $$PendingSyncActionsTableAnnotationComposer,
    $$PendingSyncActionsTableCreateCompanionBuilder,
    $$PendingSyncActionsTableUpdateCompanionBuilder,
    (
      PendingSyncAction,
      BaseReferences<_$AppDatabase, $PendingSyncActionsTable, PendingSyncAction>
    ),
    PendingSyncAction,
    PrefetchHooks Function()>;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion
    Function({
  required String entityType,
  required String cursor,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion
    Function({
  Value<String> entityType,
  Value<String> cursor,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursor => $composableBuilder(
      column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncCursorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()> {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<String> cursor = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion(
            entityType: entityType,
            cursor: cursor,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            required String cursor,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion.insert(
            entityType: entityType,
            cursor: cursor,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncCursorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalLeadsTableTableManager get localLeads =>
      $$LocalLeadsTableTableManager(_db, _db.localLeads);
  $$LocalJobsTableTableManager get localJobs =>
      $$LocalJobsTableTableManager(_db, _db.localJobs);
  $$LocalFollowupSequencesTableTableManager get localFollowupSequences =>
      $$LocalFollowupSequencesTableTableManager(
          _db, _db.localFollowupSequences);
  $$LocalFollowupMessagesTableTableManager get localFollowupMessages =>
      $$LocalFollowupMessagesTableTableManager(_db, _db.localFollowupMessages);
  $$LocalCallLogsTableTableManager get localCallLogs =>
      $$LocalCallLogsTableTableManager(_db, _db.localCallLogs);
  $$LocalMessageTemplatesTableTableManager get localMessageTemplates =>
      $$LocalMessageTemplatesTableTableManager(_db, _db.localMessageTemplates);
  $$LocalOrganizationsTableTableManager get localOrganizations =>
      $$LocalOrganizationsTableTableManager(_db, _db.localOrganizations);
  $$LocalProfilesTableTableManager get localProfiles =>
      $$LocalProfilesTableTableManager(_db, _db.localProfiles);
  $$PendingSyncActionsTableTableManager get pendingSyncActions =>
      $$PendingSyncActionsTableTableManager(_db, _db.pendingSyncActions);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
