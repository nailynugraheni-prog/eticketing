import 'package:flutter/material.dart';
import '../../data/repositories/user_management_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final _repo = UserManagementRepository();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _repo.getAllUsers();
    } catch (e) {
      debugPrint('Error load users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRole(String userId, String newRole) async {
    await _repo.updateRole(userId: userId, newRole: newRole);
    await loadUsers();
  }

  Future<void> toggleActive(String userId, bool isActive) async {
    await _repo.toggleActive(userId: userId, isActive: isActive);
    await loadUsers();
  }

  Future<void> sendPasswordReset(String email) async {
    await _repo.sendPasswordReset(email);
  }
}