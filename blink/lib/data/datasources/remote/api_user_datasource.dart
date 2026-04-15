import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import 'api_client.dart';

class ApiUserDatasource {
  final ApiClient _client;

  ApiUserDatasource(this._client);

  Dio get _dio => _client.dio;

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserModel.fromApi(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to fetch user'));
    }
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (username != null) body['username'] = username;
      if (email != null) body['email'] = email;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await _dio.patch(ApiConstants.profile, data: body);
      return UserModel.fromApi(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to update profile'));
    }
  }

  Future<String> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.post(ApiConstants.avatar, data: formData);
      return response.data['user']['avatarUrl'] as String;
    } on DioException catch (e) {
      throw ServerException(_extractMessage(e, 'Failed to upload avatar'));
    }
  }

  String _extractMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
