import 'package:flutter/material.dart';

import '../constants/app_tokens.dart';

/// Canonical job health status values and helpers.
///
/// The DB stores 'green', 'yellow', 'red' as raw strings. Use [dbValue] when
/// writing to the database and [fromDb] when reading from it.
enum JobHealthStatus {
  onTrack,
  needsAttention,
  behind;

  /// The canonical string stored in the local SQLite database.
  String get dbValue => switch (this) {
        JobHealthStatus.onTrack => 'green',
        JobHealthStatus.needsAttention => 'yellow',
        JobHealthStatus.behind => 'red',
      };

  /// Human-readable label shown in the UI.
  String get displayLabel => switch (this) {
        JobHealthStatus.onTrack => 'On Track',
        JobHealthStatus.needsAttention => 'Needs Attention',
        JobHealthStatus.behind => 'Behind Schedule',
      };

  /// Color used for status indicators and badges.
  Color get indicatorColor => switch (this) {
        JobHealthStatus.onTrack => AppTokens.success,
        JobHealthStatus.needsAttention => AppTokens.warning,
        JobHealthStatus.behind => AppTokens.danger,
      };

  /// Parse from a DB string value.
  ///
  /// Accepts both the raw DB values ('green', 'yellow', 'red') and
  /// the semantic aliases ('on_track', 'needs_attention', 'behind').
  static JobHealthStatus fromDb(String value) =>
      switch (value.trim().toLowerCase()) {
        'green' || 'on_track' => JobHealthStatus.onTrack,
        'yellow' || 'needs_attention' => JobHealthStatus.needsAttention,
        'red' || 'behind' => JobHealthStatus.behind,
        _ => JobHealthStatus.onTrack,
      };
}
