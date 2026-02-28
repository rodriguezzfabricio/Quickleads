// Sync status tracking for the UI and sync engine.

/// Current state of the sync engine.
enum SyncStatus {
  /// No sync in progress, device is online.
  idle,

  /// Actively pushing or pulling data.
  syncing,

  /// Last sync attempt failed (will retry).
  error,

  /// Device has no connectivity.
  offline,
}

/// Result of a sync cycle (push + pull).
class SyncResult {
  const SyncResult({
    required this.status,
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.conflictCount = 0,
    this.errorMessage,
  });

  /// Outcome status.
  final SyncStatus status;

  /// Number of mutations successfully pushed to server.
  final int pushedCount;

  /// Number of entities pulled from server.
  final int pulledCount;

  /// Number of conflicts detected during push.
  final int conflictCount;

  /// Human-readable error message, if any.
  final String? errorMessage;

  /// Convenience factory for a successful sync.
  factory SyncResult.success({
    int pushedCount = 0,
    int pulledCount = 0,
    int conflictCount = 0,
  }) {
    return SyncResult(
      status: SyncStatus.idle,
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      conflictCount: conflictCount,
    );
  }

  /// Convenience factory for an error result.
  factory SyncResult.error(String message) {
    return SyncResult(
      status: SyncStatus.error,
      errorMessage: message,
    );
  }

  /// Convenience factory for offline state.
  factory SyncResult.offline() {
    return const SyncResult(status: SyncStatus.offline);
  }

  @override
  String toString() =>
      'SyncResult(status: $status, pushed: $pushedCount, '
      'pulled: $pulledCount, conflicts: $conflictCount'
      '${errorMessage != null ? ', error: $errorMessage' : ''})';
}
