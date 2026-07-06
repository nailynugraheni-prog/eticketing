import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/user_session_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  UserSessionModel? _session;

  bool get isLoading => _isLoading;
  UserSessionModel? get session => _session;
  bool get isLoggedIn => _session != null;
  String get role => _session?.role ?? 'guest';

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _supabase.auth.signInWithPassword(
        email: request.email,
        password: request.password,
      );

      final user = res.user;
      final session = res.session;

      if (user == null || session == null) {
        _isLoading = false;
        notifyListeners();

        return LoginResponseModel(
          success: false,
          message: 'Login gagal',
          token: '',
          role: 'guest',
          name: '',
        );
      }

      final profile = await _supabase
          .from('profiles')
          .select('full_name, username, role, is_active')
          .eq('id', user.id)
          .single();

// ✅ Cek status aktif — tolak login kalau akun dinonaktifkan admin (BR-002.9)
      final isActive = profile['is_active'] as bool? ?? true;
      if (!isActive) {
        await _supabase.auth.signOut();
        _isLoading = false;
        notifyListeners();

        return LoginResponseModel(
          success: false,
          message: 'Akun Anda telah dinonaktifkan. Hubungi admin.',
          token: '',
          role: 'guest',
          name: '',
        );
      }

      _session = UserSessionModel(
        token: session.accessToken,
        name: profile['full_name'] ?? '',
        username: profile['username'] ?? '',
        role: profile['role'] ?? 'user',
      );

      _isLoading = false;
      notifyListeners();

      return LoginResponseModel(
        success: true,
        message: 'Login berhasil',
        token: _session!.token,
        role: _session!.role,
        name: _session!.name,
      );
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();

      return LoginResponseModel(
        success: false,
        message: e.message,
        token: '',
        role: 'guest',
        name: '',
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      return LoginResponseModel(
        success: false,
        message: e.toString(),
        token: '',
        role: 'guest',
        name: '',
      );
    }
  }

  Future<void> register(RegisterRequestModel request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _supabase.auth.signUp(
        email: request.email,
        password: request.password,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Register gagal');
      }

      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': request.name,
        'username': request.username,
        'role': 'user',
      });

      _session = UserSessionModel(
        token: res.session?.accessToken ?? '',
        name: request.name,
        username: request.username,
        role: 'user',
      );
    } catch (_) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionFromSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final profile = await _supabase
        .from('profiles')
        .select('full_name, username, role')
        .eq('id', user.id)
        .single();

    final currentSession = _supabase.auth.currentSession;

    _session = UserSessionModel(
      token: currentSession?.accessToken ?? '',
      name: profile['full_name'] ?? '',
      username: profile['username'] ?? '',
      role: profile['role'] ?? 'user',
    );

    notifyListeners();
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _session = null;
    notifyListeners();
  }

  void seedGuest() {
    _session = null;
    notifyListeners();
  }
}