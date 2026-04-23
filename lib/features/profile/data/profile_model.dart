class ProfileModel {
  final String name;
  final String username;
  final String role;
  final String email;
  final String phone;

  ProfileModel({
    required this.name,
    required this.username,
    required this.role,
    required this.email,
    required this.phone,
  });

  ProfileModel copyWith({
    String? name,
    String? username,
    String? role,
    String? email,
    String? phone,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}