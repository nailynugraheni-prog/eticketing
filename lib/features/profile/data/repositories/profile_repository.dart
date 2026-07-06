import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileModel?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('profiles')
        .select('full_name, username, role, email, phone')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    return ProfileModel(
      name: data['full_name'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? 'user',
      email: data['email'] ?? user.email ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Future<ProfileModel?> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;


    await _supabase.from('profiles').update({
      'full_name': name,
      'email': email,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', user.id);


    if (email != user.email) {
      await _supabase.auth.updateUser(UserAttributes(email: email));
    }

    return getCurrentProfile();
  }
}