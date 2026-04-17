import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import 'api_client.dart';

class ApiProfileDatasource {
  final ApiClient _client;

  ApiProfileDatasource(this._client);

  Future<void> updateProfile({String? displayName, String? username}) async {
    try {
      await _client.dio.patch(
        ApiConstants.profile,
        data: {
          if (displayName != null) 'displayName': displayName,
          if (username != null) 'username': username,
        },
      );
    } catch (e) {
      throw ServerException('Failed to update profile: $e');
    }
  }

  Future<void> setGhostMode(bool enabled) async {
    try {
      await _client.dio.patch(
        ApiConstants.profilePrivacy,
        data: {'ghostMode': enabled},
      );
    } catch (e) {
      throw ServerException('Failed to update ghost mode: $e');
    }
  }
}
