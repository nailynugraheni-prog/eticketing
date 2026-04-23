class UserSessionModel {
  final String token;
  final String name;
  final String username;
  final String role;

  UserSessionModel({
    required this.token,
    required this.name,
    required this.username,
    required this.role,
  });

  factory UserSessionModel.fromMap(Map<String, dynamic> map) {
    return UserSessionModel(
      token: map['token'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'name': name,
      'username': username,
      'role': role,
    };
  }
}