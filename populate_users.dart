import 'package:supabase/supabase.dart';

void main() async {
  const String supabaseUrl = 'https://pwynnhwduidrjixyhwoj.supabase.co';
  const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3eW5uaHdkdWlkcmppeHlod29qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyNzI2NDYsImV4cCI6MjA5Mzg0ODY0Nn0.O_nqkxgOjm8GxC2lXBqS9i4T52aIXOlw0GqqFnWZBoo';

  final supabase = SupabaseClient(supabaseUrl, supabaseAnonKey);

  final usersToCreate = [
    // {
    //   'email': 'admin@sabeh.com',
    //   'password': 'password123',
    //   'name': 'Admin User',
    //   'role': 'admin',
    // },
    {
      'email': 'manager@sabeh.com',
      'password': 'password123',
      'name': 'Manager User',
      'role': 'manager',
    },
    {
      'email': 'cs@sabeh.com',
      'password': 'password123',
      'name': 'Customer Service',
      'role': 'customer_service',
    },
    {
      'email': 'delivery_manager@sabeh.com',
      'password': 'password123',
      'name': 'Delivery Manager',
      'role': 'delivery_manager',
    },
    {
      'email': 'delivery1@sabeh.com',
      'password': 'password123',
      'name': 'Delivery User 1',
      'role': 'delivery_user',
    },
  ];

  for (final u in usersToCreate) {
    try {
      print('Signing up ${u['email']}...');
      final response = await supabase.auth.signUp(
        email: u['email']!,
        password: u['password']!,
      );

      final userId = response.user?.id;
      if (userId != null) {
        print('User created with ID: $userId');

        // Wait briefly for triggers (if any) to run, then try to update or insert profile
        await Future.delayed(Duration(seconds: 1));

        print('Upserting profile for ${u['email']}...');
        await supabase.from('staff_profiles').upsert({
          'id': userId,
          'name': u['name'],
          'role': u['role'],
          'is_active': true,
        });
        print('Profile updated for ${u['email']}.');
      }
    } catch (e, st) {
      print('Error creating user ${u['email']}: $e');
      print(st);
    }
  }
}
