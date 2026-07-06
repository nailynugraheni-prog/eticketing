import 'package:flutter/material.dart';
import '../../data/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final _repo = ProfileRepository();

  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _profile = await _repo.getCurrentProfile();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    _profile = await _repo.updateProfile(
      name: name,
      email: email,
      phone: phone,
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}