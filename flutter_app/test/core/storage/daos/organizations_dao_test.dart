import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:crewcommand_mobile/core/storage/app_database.dart';
import 'package:crewcommand_mobile/core/storage/daos/organizations_dao.dart';

void main() {
  late AppDatabase db;
  late OrganizationsDao organizationsDao;

  setUp(() {
    db = AppDatabase.memory();
    organizationsDao = db.organizationsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('OrganizationsDao', () {
    test('upsert + get profile by auth user id', () async {
      await organizationsDao.upsertOrganization(
        LocalOrganizationsCompanion.insert(
          id: 'org-1',
          name: 'CrewCommand LLC',
          timezone: const Value('America/New_York'),
        ),
      );
      await organizationsDao.upsertProfile(
        LocalProfilesCompanion.insert(
          id: 'profile-1',
          organizationId: 'org-1',
          authUserId: 'auth-user-1',
          fullName: 'Fabricio Rodriguez',
          role: const Value('owner'),
          phoneE164: const Value('+15550001111'),
        ),
      );

      final profile =
          await organizationsDao.getProfileByAuthUserId('auth-user-1');
      expect(profile, isNotNull);
      expect(profile!.id, 'profile-1');
      expect(profile.organizationId, 'org-1');
      expect(profile.fullName, 'Fabricio Rodriguez');
    });

    test('update organization and profile fields', () async {
      await organizationsDao.upsertOrganization(
        LocalOrganizationsCompanion.insert(
          id: 'org-2',
          name: 'Old Name',
          timezone: const Value('America/New_York'),
        ),
      );
      await organizationsDao.upsertProfile(
        LocalProfilesCompanion.insert(
          id: 'profile-2',
          organizationId: 'org-2',
          authUserId: 'auth-user-2',
          fullName: 'Old Name',
        ),
      );

      await organizationsDao.updateOrganizationName('org-2', 'New Name');
      await organizationsDao.updateProfileName('profile-2', 'New Contractor');
      await organizationsDao.updateProfilePhone('profile-2', '+15550002222');

      final org = await organizationsDao.getOrganization('org-2');
      final profile = await organizationsDao.getProfile('profile-2');
      expect(org, isNotNull);
      expect(org!.name, 'New Name');
      expect(profile, isNotNull);
      expect(profile!.fullName, 'New Contractor');
      expect(profile.phoneE164, '+15550002222');
    });
  });
}
