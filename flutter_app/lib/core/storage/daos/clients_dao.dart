import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/clients_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'clients_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [LocalClients, PendingSyncActions])
class ClientsDao extends DatabaseAccessor<AppDatabase> with _$ClientsDaoMixin {
  ClientsDao(super.db);

  Stream<List<LocalClient>> watchClientsByOrg(String orgId) {
    return (select(localClients)
          ..where((c) => c.organizationId.equals(orgId))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .watch();
  }

  Stream<LocalClient?> watchClientById(String id) {
    return (select(localClients)..where((c) => c.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<LocalClient?> getClientById(String id) {
    return (select(localClients)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<LocalClient?> getClientBySourceLeadId(
    String orgId,
    String sourceLeadId,
  ) {
    return (select(localClients)
          ..where((c) => c.organizationId.equals(orgId))
          ..where((c) => c.sourceLeadId.equals(sourceLeadId))
          ..where((c) => c.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> createClient(LocalClientsCompanion client) {
    return transaction(() async {
      await into(localClients).insert(
        client.copyWith(needsSync: const Value(true)),
      );
      await _queueSync(
        entityId: client.id.value,
        mutationType: 'insert',
        baseVersion: null,
        payload: _clientCompanionToJson(client),
      );
    });
  }

  Future<void> updateClient({
    required String id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? sourceLeadId,
    int? projectCount,
    required int currentVersion,
  }) {
    return transaction(() async {
      final nextVersion = currentVersion + 1;
      await (update(localClients)..where((c) => c.id.equals(id))).write(
        LocalClientsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          phone: Value(phone),
          email: Value(email),
          address: Value(address),
          notes: Value(notes),
          sourceLeadId: Value(sourceLeadId),
          projectCount: projectCount != null
              ? Value(projectCount)
              : const Value.absent(),
          version: Value(nextVersion),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );

      await _queueSync(
        entityId: id,
        mutationType: 'update',
        baseVersion: currentVersion,
        payload: {
          'id': id,
          if (name != null) 'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'notes': notes,
          'source_lead_id': sourceLeadId,
          if (projectCount != null) 'project_count': projectCount,
          'version': nextVersion,
        },
      );
    });
  }

  Future<void> softDeleteClient(String id, int currentVersion) {
    return transaction(() async {
      final now = DateTime.now();
      final nextVersion = currentVersion + 1;
      await (update(localClients)..where((c) => c.id.equals(id))).write(
        LocalClientsCompanion(
          deletedAt: Value(now),
          version: Value(nextVersion),
          updatedAt: Value(now),
          needsSync: const Value(true),
        ),
      );

      await _queueSync(
        entityId: id,
        mutationType: 'delete',
        baseVersion: currentVersion,
        payload: {
          'id': id,
          'deleted_at': now.toIso8601String(),
          'version': nextVersion,
        },
      );
    });
  }

  Future<void> upsertFromServer(List<LocalClientsCompanion> clients) {
    return batch((b) {
      for (final client in clients) {
        b.insert(
          localClients,
          client.copyWith(
            needsSync: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> _queueSync({
    required String entityId,
    required String mutationType,
    required int? baseVersion,
    required Map<String, dynamic> payload,
  }) {
    return into(pendingSyncActions).insert(
      PendingSyncActionsCompanion.insert(
        id: _uuid.v4(),
        clientMutationId: _uuid.v4(),
        entityType: 'client',
        entityId: Value(entityId),
        mutationType: mutationType,
        baseVersion: Value(baseVersion),
        payload: jsonEncode(payload),
      ),
    );
  }

  Map<String, dynamic> _clientCompanionToJson(LocalClientsCompanion c) {
    return {
      'id': c.id.value,
      'organization_id': c.organizationId.value,
      'name': c.name.value,
      if (c.phone.present) 'phone': c.phone.value,
      if (c.email.present) 'email': c.email.value,
      if (c.address.present) 'address': c.address.value,
      if (c.notes.present) 'notes': c.notes.value,
      if (c.sourceLeadId.present) 'source_lead_id': c.sourceLeadId.value,
      if (c.projectCount.present) 'project_count': c.projectCount.value,
      if (c.version.present) 'version': c.version.value,
    };
  }
}
