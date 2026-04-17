import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/friend_entity.dart';
import '../../../domain/entities/friend_request_entity.dart';
import 'api_client.dart';

class ApiFriendsDatasource {
  final ApiClient _client;

  ApiFriendsDatasource(this._client);

  Future<List<FriendEntity>> search(String query) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.friendsSearch,
        queryParameters: {'q': query},
      );
      final list = (response.data['results'] ?? response.data['users'] ?? [])
          as List<dynamic>;
      return list
          .map((j) => FriendEntity.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Search failed: $e');
    }
  }

  Future<List<FriendEntity>> getFriends() async {
    try {
      final response = await _client.dio.get(ApiConstants.friends);
      final list = (response.data['friends'] ?? response.data) as List<dynamic>;
      return list
          .map((j) => FriendEntity.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to load friends: $e');
    }
  }

  Future<({List<FriendRequestEntity> incoming, List<FriendRequestEntity> outgoing})>
      getRequests() async {
    try {
      final response = await _client.dio.get(ApiConstants.friendsRequests);
      final data = response.data as Map<String, dynamic>;
      final incomingList = (data['incoming'] ?? []) as List<dynamic>;
      final outgoingList = (data['outgoing'] ?? []) as List<dynamic>;
      return (
        incoming: incomingList
            .map((j) => FriendRequestEntity.fromJson(j as Map<String, dynamic>))
            .toList(),
        outgoing: outgoingList
            .map((j) => FriendRequestEntity.fromJson(j as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw ServerException('Failed to load requests: $e');
    }
  }

  Future<void> sendRequest(String username) async {
    try {
      await _client.dio.post(
        ApiConstants.friendRequest,
        data: {'username': username},
      );
    } catch (e) {
      throw ServerException('Failed to send request: $e');
    }
  }

  Future<void> respondRequest(String requestId, {required bool accept}) async {
    try {
      await _client.dio.patch(
        ApiConstants.friendRespond(requestId),
        data: {'action': accept ? 'accepted' : 'declined'},
      );
    } catch (e) {
      throw ServerException('Failed to respond: $e');
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await _client.dio.delete(ApiConstants.friendCancelRequest(requestId));
    } catch (e) {
      throw ServerException('Failed to cancel request: $e');
    }
  }

  Future<void> unfriend(String friendId) async {
    try {
      await _client.dio.delete(ApiConstants.unfriend(friendId));
    } catch (e) {
      throw ServerException('Failed to unfriend: $e');
    }
  }
}
