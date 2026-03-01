/// Canonical job phase values and helpers.
///
/// The DB stores lowercase snake_case strings. Use [dbValue] when writing
/// to the database and [fromDb] when reading from it.
enum JobPhase {
  demo,
  rough,
  electricalPlumbing,
  finishing,
  walkthrough,
  complete;

  /// The canonical string stored in the local SQLite database.
  String get dbValue => switch (this) {
        JobPhase.demo => 'demo',
        JobPhase.rough => 'rough',
        JobPhase.electricalPlumbing => 'electrical_plumbing',
        JobPhase.finishing => 'finishing',
        JobPhase.walkthrough => 'walkthrough',
        JobPhase.complete => 'complete',
      };

  /// Human-readable label shown in the UI.
  String get displayLabel => switch (this) {
        JobPhase.demo => 'Demo',
        JobPhase.rough => 'Rough',
        JobPhase.electricalPlumbing => 'Electrical / Plumbing',
        JobPhase.finishing => 'Finishing',
        JobPhase.walkthrough => 'Walkthrough',
        JobPhase.complete => 'Complete',
      };

  /// Whether this is the terminal phase (no further advancement possible).
  bool get isFinal => this == JobPhase.complete;

  /// Parse from a DB or legacy string value.
  ///
  /// Handles the old incorrect values that were used in [job_detail_screen.dart]
  /// (scheduled, in_progress, punch_list, completed) so stale data doesn't crash.
  static JobPhase fromDb(String value) =>
      switch (value.trim().toLowerCase()) {
        'demo' => JobPhase.demo,
        'rough' => JobPhase.rough,
        'electrical_plumbing' => JobPhase.electricalPlumbing,
        'finishing' => JobPhase.finishing,
        'walkthrough' => JobPhase.walkthrough,
        'complete' => JobPhase.complete,
        // Legacy wrong values — map to nearest correct phase
        'scheduled' => JobPhase.rough,
        'in_progress' => JobPhase.finishing,
        'punch_list' => JobPhase.walkthrough,
        'completed' => JobPhase.complete,
        _ => JobPhase.demo,
      };

  /// The six phases in progression order.
  static const orderedValues = [
    JobPhase.demo,
    JobPhase.rough,
    JobPhase.electricalPlumbing,
    JobPhase.finishing,
    JobPhase.walkthrough,
    JobPhase.complete,
  ];
}
