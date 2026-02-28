import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/message_templates_table.dart';

part 'templates_dao.g.dart';

@DriftAccessor(tables: [LocalMessageTemplates])
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
