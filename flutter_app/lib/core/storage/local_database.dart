import 'package:flutter_riverpod/flutter_riverpod.dart';

final localDatabaseReadyProvider = Provider<bool>((ref) {
  // TODO(phase-2): Add Drift schema and open local SQLite instance.
  return false;
});
