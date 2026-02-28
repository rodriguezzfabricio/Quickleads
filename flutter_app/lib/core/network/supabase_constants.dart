class SupabaseConstants {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://seuoakzowzmqsmbqzznm.supabase.co',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNldW9ha3pvd3ptcXNtYnF6em5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMjUxMjksImV4cCI6MjA4NzgwMTEyOX0.k_c1kPZznrMF-F6AkPGnVhBTTd6C9FgKzq8ld9hXccs',
  );

  static const magicLinkRedirectUrl = String.fromEnvironment(
    'SUPABASE_MAGIC_LINK_REDIRECT_URL',
    defaultValue: 'io.supabase.crewcommand://login-callback',
  );
}
