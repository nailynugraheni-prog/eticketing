class RegisterRequestModel {
  final String name;
  final String username;
  final String email;
  final String password;
  final String role;

  RegisterRequestModel({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });
}