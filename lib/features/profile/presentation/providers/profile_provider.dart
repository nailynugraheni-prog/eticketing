import 'package:flutter/material.dart';
import '../../data/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel _profile = ProfileModel(
    name: 'User Aplikasi',
    username: 'user01',
    role: 'user',
    email: 'user01@mail.com',
    phone: '08123456789',
  );

  ProfileModel get profile => _profile;

  void loadDummyProfile(String role) {
    if (role == 'staff' || role == 'admin') {
      _profile = ProfileModel(
        name: 'Admin Helpdesk',
        username: 'helpdesk01',
        role: 'staff',
        email: 'helpdesk01@mail.com',
        phone: '08987654321',
      );
    } else {
      _profile = ProfileModel(
        name: 'User Aplikasi',
        username: 'user01',
        role: 'user',
        email: 'user01@mail.com',
        phone: '08123456789',
      );
    }
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }
}