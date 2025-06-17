import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:msport/model/user.dart';


class DBUser {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'users';

  // CREATE - Add new user
  Future<User1?> createUser(User1 user) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(user.toMap())
          .select()
          .single();
      
      return User1.fromMap(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }
}