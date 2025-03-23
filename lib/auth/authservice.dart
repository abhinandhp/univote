import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //sign in
  Future<AuthResponse> signIn(String email, String pass) async {
    return await _supabase.auth.signInWithPassword(
      password: pass,
      email: email,
    );
  }

  //signup
  Future<void> signUp(String email, String pass,String name) async {
    // return await _supabase.auth.signUp(
    //   password: pass,
    //   email: email,
    // );

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: pass,
      );

      if (response.user != null) {
        // Insert user profile data
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'username': name,
          'is_admin': false, // Default as regular user
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //signout
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }
}
