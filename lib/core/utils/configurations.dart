class AppConfigurations {
  AppConfigurations._();

  static const String supabaseUrl            = 'https://pwynnhwduidrjixyhwoj.supabase.co';
  static const String supabaseAnonKey        = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3eW5uaHdkdWlkcmppeHlod29qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyNzI2NDYsImV4cCI6MjA5Mzg0ODY0Nn0.O_nqkxgOjm8GxC2lXBqS9i4T52aIXOlw0GqqFnWZBoo';
  // Supabase Dashboard → Project Settings → API → service_role (secret) key
  // Required for creating staff accounts via Admin API.
  // NEVER ship this in a production build — use env vars or a backend proxy instead.
  static const String supabaseServiceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3eW5uaHdkdWlkcmppeHlod29qIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3ODI3MjY0NiwiZXhwIjoyMDkzODQ4NjQ2fQ.cej-xpaKeaZrFbloPjCTbGh6GYdV7ocVIQ0Tn1S5zR0';
}
