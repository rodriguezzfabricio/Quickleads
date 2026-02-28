class LeadStatusMapper {
  const LeadStatusMapper._();

  static const callbackDb = 'new_callback';
  static const estimateDb = 'estimate_sent';
  static const wonDb = 'won';
  static const coldDb = 'cold';

  static const allCanonical = {
    callbackDb,
    estimateDb,
    wonDb,
    coldDb,
  };

  static String canonicalize(String status) {
    final trimmed = status.trim().toLowerCase();
    return switch (trimmed) {
      'call-back-now' || 'new' || 'new_callback' => callbackDb,
      'estimate-sent' || 'estimate_sent' || 'quoted' => estimateDb,
      'won' => wonDb,
      'cold' || 'lost' => coldDb,
      _ => trimmed,
    };
  }

  static String toUiLabel(String status) {
    return switch (canonicalize(status)) {
      callbackDb => 'Callback',
      estimateDb => 'Estimate',
      wonDb => 'Won',
      coldDb => 'Cold',
      _ => status,
    };
  }

  static bool isEstimateLike(String status) {
    return canonicalize(status) == estimateDb;
  }

  static bool isTerminal(String status) {
    final canonical = canonicalize(status);
    return canonical == wonDb || canonical == coldDb;
  }
}
