import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/friend_location_entity.dart';
import 'api_client.dart';

class ApiLocationDatasource {
  final ApiClient _client;

  ApiLocationDatasource(this._client);

  Future<void> updateLocation({
    required double lat,
    required double lng,
    double? accuracy,
  }) async {
    try {
      await _client.dio.post(
        ApiConstants.locationUpdate,
        data: {
          'lat': lat,
          'lng': lng,
          if (accuracy != null) 'accuracy': accuracy,
        },
      );
    } catch (e) {
      throw ServerException('Failed to update location: $e');
    }
  }

  Future<List<FriendLocationEntity>> getVisibleFriends() async {
    try {
      final response = await _client.dio.get(ApiConstants.visibleFriends);
      final list = response.data['friends'] as List<dynamic>;
      return list
          .map((j) => FriendLocationEntity.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load friends: $e');
    }
  }

  Future<void> shareLocation(String friendId, {int? durationMinutes}) async {
    try {
      await _client.dio.post(
        ApiConstants.shareLocation(friendId),
        data: durationMinutes != null
            ? {'durationMinutes': durationMinutes}
            : null,
      );
    } catch (e) {
      throw ServerException('Failed to share location: $e');
    }
  }

  Future<void> unshareLocation(String friendId) async {
    try {
      await _client.dio.delete(ApiConstants.unshareLocation(friendId));
    } catch (e) {
      throw ServerException('Failed to unshare location: $e');
    }
  }
}
