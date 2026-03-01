import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/message_templates_table.dart';
import '../tables/pending_sync_actions_table.dart';

part 'templates_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [LocalMessageTemplates, PendingSyncActions])
class TemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$TemplatesDaoMixin {
  TemplatesDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// Watch all active templates for an org.
  Stream<List<LocalMessageTemplate>> watchActiveTemplates(String orgId) {
    return (select(localMessageTemplates)
          ..where((t) => t.organizationId.equals(orgId))
          ..where((t) => t.active.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.templateKey)]))
        .watch();
  }

  /// Get a specific template by key.
  Future<LocalMessageTemplate?> getTemplateByKey(
    String orgId,
    String templateKey,
  ) {
    return (select(localMessageTemplates)
          ..where((t) => t.organizationId.equals(orgId))
          ..where((t) => t.templateKey.equals(templateKey)))
        .getSingleOrNull();
  }

  // ── Mutations ────────────────────────────────────────────────────

  /// Update an existing template's message bodies.
  ///
  /// Marks [needsSync] so the sync engine picks it up for the server.
  Future<void> updateTemplate({
    required String id,
    required String smsBody,
    String? emailSubject,
    String? emailBody,
  }) async {
    await transaction(() async {
      await (update(localMessageTemplates)..where((t) => t.id.equals(id)))
          .write(
        LocalMessageTemplatesCompanion(
          smsBody: Value(smsBody),
          emailSubject: Value(emailSubject),
          emailBody: Value(emailBody),
          updatedAt: Value(DateTime.now()),
          needsSync: const Value(true),
        ),
      );
      await into(pendingSyncActions).insert(
        PendingSyncActionsCompanion.insert(
          id: _uuid.v4(),
          clientMutationId: _uuid.v4(),
          entityType: 'message_template',
          entityId: Value(id),
          mutationType: 'update',
          payload: jsonEncode({
            'id': id,
            'sms_body': smsBody,
            'email_subject': emailSubject,
            'email_body': emailBody,
          }),
        ),
      );
    });
  }

  /// Insert a default template if none exists for the given org + key combination.
  ///
  /// Uses `insertOrIgnore` so it is safe to call repeatedly on app launch.
  Future<void> upsertDefaultTemplate({
    required String id,
    required String orgId,
    required String templateKey,
    required String smsBody,
  }) async {
    await into(localMessageTemplates).insert(
      LocalMessageTemplatesCompanion.insert(
        id: id,
        organizationId: orgId,
        templateKey: templateKey,
        smsBody: smsBody,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  // ── Server Sync ─────────────────────────────────────────────────

  /// Bulk upsert templates from server (no outbox entries).
  /// Templates are managed server-side; local is read-only cache.
  Future<void> upsertFromServer(
    List<LocalMessageTemplatesCompanion> serverTemplates,
  ) {
    return batch((b) {
      for (final template in serverTemplates) {
        b.insert(
          localMessageTemplates,
          template.copyWith(
            needsSync: const Value(false),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
