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

  /// Updates one or more privacy fields. Each parameter is optional —
  /// only provided fields are sent. Server enum: friends | circles | nobody.
  Future<Map<String, dynamic>> updatePrivacy({
    String? locationVisibility,
    String? lastSeenVisibility,
    String? batteryVisibility,
  }) async {
    try {
      final res = await _client.dio.patch(
        ApiConstants.profilePrivacy,
        data: {
          if (locationVisibility != null)
            'locationVisibility': locationVisibility,
          if (lastSeenVisibility != null)
            'lastSeenVisibility': lastSeenVisibility,
          if (batteryVisibility != null) 'batteryVisibility': batteryVisibility,
        },
      );
      return Map<String, dynamic>.from(res.data['privacy'] as Map);
    } catch (e) {
      throw ServerException('Failed to update privacy: $e');
    }
  }

  Future<List<String>> ghostFromAdd(String friendId) async {
    try {
      final res = await _client.dio.put(
        ApiConstants.ghostFrom(friendId),
      );
      return ((res.data['ghostFromList'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      throw ServerException('Failed to add ghost-from: $e');
    }
  }

  Future<List<String>> ghostFromRemove(String friendId) async {
    try {
      final res = await _client.dio.delete(
        ApiConstants.ghostFrom(friendId),
      );
      return ((res.data['ghostFromList'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList();
    } catch (e) {
      throw ServerException('Failed to remove ghost-from: $e');
    }
  }
}
