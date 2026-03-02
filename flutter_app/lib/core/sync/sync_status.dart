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
    this.errorCode,
    this.pushErrorMessage,
    this.pushErrorCode,
    this.pullErrorMessage,
    this.pullErrorCode,
    this.attemptedAt,
    this.completedAt,
  });

  /// Outcome status.
  final SyncStatus status;

  /// Number of mutations successfully pushed to server.
  final int pushedCount;

  /// Number of entities pulled from server.
  final int pulledCount;

  /// Number of conflicts detected during push.
  final int conflictCount;

  /// Human-readable overall error message, if any.
  final String? errorMessage;

  /// Machine-readable overall error code, if any.
  final String? errorCode;

  /// Push phase error details.
  final String? pushErrorMessage;
  final String? pushErrorCode;

  /// Pull phase error details.
  final String? pullErrorMessage;
  final String? pullErrorCode;

  /// Timing metadata for diagnostics.
  final DateTime? attemptedAt;
  final DateTime? completedAt;

  bool get hasErrors =>
      status == SyncStatus.error ||
      (errorMessage?.isNotEmpty ?? false) ||
      (pushErrorMessage?.isNotEmpty ?? false) ||
      (pullErrorMessage?.isNotEmpty ?? false);

  /// Convenience factory for a successful sync.
  factory SyncResult.success({
    int pushedCount = 0,
    int pulledCount = 0,
    int conflictCount = 0,
    DateTime? attemptedAt,
    DateTime? completedAt,
  }) {
    return SyncResult(
      status: SyncStatus.idle,
      pushedCount: pushedCount,
      pulledCount: pulledCount,
      conflictCount: conflictCount,
      attemptedAt: attemptedAt,
      completedAt: completedAt,
    );
  }

  /// Convenience factory for an error result.
  factory SyncResult.error(
    String message, {
    String? errorCode,
    String? pushErrorMessage,
    String? pushErrorCode,
    String? pullErrorMessage,
    String? pullErrorCode,
    DateTime? attemptedAt,
    DateTime? completedAt,
  }) {
    return SyncResult(
      status: SyncStatus.error,
      errorMessage: message,
      errorCode: errorCode,
      pushErrorMessage: pushErrorMessage,
      pushErrorCode: pushErrorCode,
      pullErrorMessage: pullErrorMessage,
      pullErrorCode: pullErrorCode,
      attemptedAt: attemptedAt,
      completedAt: completedAt,
    );
  }

  /// Convenience factory for offline state.
  factory SyncResult.offline({
    DateTime? attemptedAt,
    DateTime? completedAt,
  }) {
    return SyncResult(
      status: SyncStatus.offline,
      errorMessage: 'Device is offline.',
      errorCode: 'offline',
      attemptedAt: attemptedAt,
      completedAt: completedAt,
    );
  }

  @override
  String toString() => 'SyncResult(status: $status, pushed: $pushedCount, '
      'pulled: $pulledCount, conflicts: $conflictCount'
      '${errorCode != null ? ', code: $errorCode' : ''}'
      '${errorMessage != null ? ', error: $errorMessage' : ''}'
      '${pushErrorMessage != null ? ', pushError: $pushErrorMessage' : ''}'
      '${pullErrorMessage != null ? ', pullError: $pullErrorMessage' : ''})';
}

/// Snapshot used by settings diagnostics UI.
class SyncDiagnostics {
  const SyncDiagnostics({
    this.currentStatus = SyncStatus.idle,
    this.lastAttemptAt,
    this.lastCompletedAt,
    this.lastSuccessAt,
    this.lastPushedCount = 0,
    this.lastPulledCount = 0,
    this.lastConflictCount = 0,
    this.lastErrorMessage,
    this.lastErrorCode,
    this.lastPushErrorMessage,
    this.lastPushErrorCode,
    this.lastPullErrorMessage,
    this.lastPullErrorCode,
  });

  final SyncStatus currentStatus;
  final DateTime? lastAttemptAt;
  final DateTime? lastCompletedAt;
  final DateTime? lastSuccessAt;
  final int lastPushedCount;
  final int lastPulledCount;
  final int lastConflictCount;
  final String? lastErrorMessage;
  final String? lastErrorCode;
  final String? lastPushErrorMessage;
  final String? lastPushErrorCode;
  final String? lastPullErrorMessage;
  final String? lastPullErrorCode;
}
