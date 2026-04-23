class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final String role;
  final String name;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.role,
    required this.name,
  });

  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    return LoginResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      token: map['token'] ?? '',
      role: map['role'] ?? 'guest',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'role': role,
      'name': name,
    };
  }
}