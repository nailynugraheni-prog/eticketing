class RegisterRequestModel {
  final String name;
  final String username;
  final String password;
  final String role;

  RegisterRequestModel({
    required this.name,
    required this.username,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}