import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/storage/app_database.dart';
import 'package:crewcommand_mobile/core/storage/daos/templates_dao.dart';

void main() {
  late AppDatabase db;
  late TemplatesDao templatesDao;

  setUp(() {
    db = AppDatabase.memory();
    templatesDao = db.templatesDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('TemplatesDao', () {
    const orgId = 'org-001';

    test('updateTemplate marks template dirty and queues sync update',
        () async {
      await db.into(db.localMessageTemplates).insert(
            LocalMessageTemplatesCompanion.insert(
              id: 'tpl-1',
              organizationId: orgId,
              templateKey: 'day_2_followup',
              smsBody: 'Original body',
            ),
          );

      await templatesDao.updateTemplate(
        id: 'tpl-1',
        smsBody: 'Updated body',
        emailSubject: 'Subject',
        emailBody: 'Body',
      );

      final template = await (db.select(db.localMessageTemplates)
            ..where((t) => t.id.equals('tpl-1')))
          .getSingle();
      expect(template.smsBody, 'Updated body');
      expect(template.emailSubject, 'Subject');
      expect(template.emailBody, 'Body');
      expect(template.needsSync, isTrue);

      final actions = await db.select(db.pendingSyncActions).get();
      expect(actions, hasLength(1));
      expect(actions.first.entityType, 'message_template');
      expect(actions.first.entityId, 'tpl-1');
      expect(actions.first.mutationType, 'update');

      final payload = jsonDecode(actions.first.payload) as Map<String, dynamic>;
      expect(payload['id'], 'tpl-1');
      expect(payload['sms_body'], 'Updated body');
      expect(payload['email_subject'], 'Subject');
      expect(payload['email_body'], 'Body');
    });

    test('upsertDefaultTemplate is idempotent for org + key', () async {
      await templatesDao.upsertDefaultTemplate(
        id: 'tpl-default',
        orgId: orgId,
        templateKey: 'day_5_followup',
        smsBody: 'Default body',
      );
      await templatesDao.upsertDefaultTemplate(
        id: 'tpl-default',
        orgId: orgId,
        templateKey: 'day_5_followup',
        smsBody: 'Changed default body',
      );

      final templates = await db.select(db.localMessageTemplates).get();
      expect(templates, hasLength(1));
      expect(templates.first.smsBody, 'Default body');
    });
  });
}
