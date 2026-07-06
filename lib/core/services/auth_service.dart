import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Login gagal: user tidak ditemukan',
        };
      }

      final profile = await _supabase
          .from('profiles')
          .select('id, full_name, username, role, phone')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        return {
          'success': false,
          'message': 'Profile tidak ditemukan. Silakan register ulang.',
        };
      }

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': {
          'id': user.id,
          'email': user.email,
          'full_name': profile['full_name'],
          'username': profile['username'],
          'role': profile['role'],
          'phone': profile['phone'],
        },
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Register gagal: user null',
        };
      }

      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'username': username,
        'role': 'user',
      });

      return {
        'success': true,
        'message': res.session == null
            ? 'Register berhasil. Cek email untuk verifikasi.'
            : 'Register berhasil',
        'needsVerification': res.session == null,
        'user': {
          'id': user.id,
          'email': user.email,
          'full_name': fullName,
          'username': username,
          'role': 'user',
        },
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await _supabase.auth.signOut();
      return {
        'success': true,
        'message': 'Logout berhasil',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    String redirectTo = 'eticketing://reset-password',
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      return {
        'success': true,
        'message': 'Link reset password sudah dikirim ke email',
      };
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // ✅ fix dari .single()

      if (profile == null) return null;

      return Map<String, dynamic>.from(profile);
    } catch (_) {
      return null;
    }
  }
}