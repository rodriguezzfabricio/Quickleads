import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// Provider that exposes the local database readiness state.
///
/// The database is opened lazily via [appDatabaseProvider] in providers.dart.
/// This provider exists for backward-compatibility with the existing stub
/// and for screens that need to check if the database is available.
final localDatabaseReadyProvider = Provider<bool>((ref) {
  // The database opens lazily when first accessed through appDatabaseProvider.
  // If we can read the provider without error, the database is ready.
  try {
    ref.watch(appDatabaseProvider);
    return true;
  } catch (_) {
    return false;
  }
});
