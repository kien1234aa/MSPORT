import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //login with email and password
  Future<AuthResponse> loginWithEmail (String email,String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password:password,
      );
  }
  //register with email and password
  Future<AuthResponse> registerWitEmail(String email,String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      );
  }

  //log out
  Future<void> logout() async{
    return await _supabase.auth.signOut();
  }


}