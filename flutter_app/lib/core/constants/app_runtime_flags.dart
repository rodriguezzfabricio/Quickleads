abstract final class AppRuntimeFlags {
  /// Explicit local/demo mode toggle. Keep disabled for real backend debugging.
  static const enableDebugMockSeed = bool.fromEnvironment(
    'ENABLE_DEBUG_MOCK_SEED',
    defaultValue: false,
  );
}
