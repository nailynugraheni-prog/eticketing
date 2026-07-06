import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final data = await _supabase
        .from('profiles')
        .select('id, full_name, username, email, role, is_active')
        .order('full_name', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> updateRole({
    required String userId,
    required String newRole,
  }) async {
    await _supabase
        .from('profiles')
        .update({'role': newRole})
        .eq('id', userId);
  }

  Future<void> toggleActive({
    required String userId,
    required bool isActive,
  }) async {
    await _supabase
        .from('profiles')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  // ✅ Kirim email reset password (bukan admin set password langsung)
  //    Ini pendekatan standar Supabase untuk client-side app
  Future<void> sendPasswordReset(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}