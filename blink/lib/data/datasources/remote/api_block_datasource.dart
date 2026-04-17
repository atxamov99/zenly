import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import 'api_client.dart';

class ApiBlockDatasource {
  final ApiClient _client;

  ApiBlockDatasource(this._client);

  Future<void> block(String userId) async {
    try {
      await _client.dio.post(ApiConstants.blockUser(userId));
    } catch (e) {
      throw ServerException('Failed to block: $e');
    }
  }

  Future<void> unblock(String userId) async {
    try {
      await _client.dio.delete(ApiConstants.unblockUser(userId));
    } catch (e) {
      throw ServerException('Failed to unblock: $e');
    }
  }

  Future<List<String>> getBlockedIds() async {
    try {
      final response = await _client.dio.get(ApiConstants.blocks);
      final list = (response.data['blocked'] ?? response.data) as List<dynamic>;
      return list
          .map((j) => (j is Map ? (j['userId'] ?? j['_id']) : j).toString())
          .toList();
    } catch (e) {
      throw ServerException('Failed to load blocks: $e');
    }
  }
}
