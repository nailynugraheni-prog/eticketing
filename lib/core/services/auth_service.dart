import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'username': username,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _dioClient.dio.post(ApiConstants.logout);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String username,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.resetPassword,
      data: {'username': username},
    );
    return response.data as Map<String, dynamic>;
  }
}