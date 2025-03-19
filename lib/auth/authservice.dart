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
  Future<AuthResponse> signUp(String email, String pass) async {
    return await _supabase.auth.signUp(
      password: pass,
      email: email,
    );
  }

  //signout
  Future<void> signOut() async{
    return await _supabase.auth.signOut();
  }


}
