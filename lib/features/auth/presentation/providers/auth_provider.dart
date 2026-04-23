import 'package:flutter/material.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/user_session_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  UserSessionModel? _session;

  bool get isLoading => _isLoading;
  UserSessionModel? get session => _session;
  bool get isLoggedIn => _session != null;
  String get role => _session?.role ?? 'guest';

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final name = request.role == 'staff'
        ? 'Admin Helpdesk'
        : request.role == 'admin'
        ? 'Administrator'
        : 'User Aplikasi';

    _session = UserSessionModel(
      token: 'dummy_token_${request.role}',
      name: name,
      username: request.username,
      role: request.role,
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
  }

  Future<void> register(RegisterRequestModel request) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    _session = UserSessionModel(
      token: 'dummy_token_user',
      name: request.name,
      username: request.username,
      role: request.role,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String username) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _isLoading = false;
    notifyListeners();
  }

  void seedGuest() {
    _session = null;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }
}