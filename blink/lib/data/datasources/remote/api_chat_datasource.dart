import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/message_model.dart';
import 'api_client.dart';

class ApiChatDatasource {
  final ApiClient _client;
  ApiChatDatasource(this._client);
  Dio get _dio => _client.dio;

  Future<List<dynamic>> fetchConversationsRaw() async {
    try {
      final res = await _dio.get(ApiConstants.chats);
      return (res.data['conversations'] as List<dynamic>?) ?? const [];
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch conversations'));
    }
  }

  Future<List<MessageModel>> fetchMessages({
    required String friendId,
    DateTime? before,
    int limit = 30,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.chatMessages(friendId),
        queryParameters: {
          if (before != null) 'before': before.toIso8601String(),
          'limit': limit,
        },
      );
      final list = (res.data['messages'] as List<dynamic>?) ?? const [];
      return list
          .map((e) => MessageModel.fromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch messages'));
    }
  }

  Future<MessageModel> sendText({
    required String friendId,
    required String text,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.chatMessages(friendId),
        data: {'type': 'text', 'text': text},
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send message'));
    }
  }

  Future<MessageModel> sendImage({
    required String friendId,
    required String imagePath,
  }) async {
    try {
      final form = FormData.fromMap({
        'type': 'image',
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(Platform.pathSeparator).last,
        ),
      });
      final res = await _dio.post(
        ApiConstants.chatMessages(friendId),
        data: form,
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send image'));
    }
  }

  Future<MessageModel> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final res = await _dio.patch(
        ApiConstants.editMessage(messageId),
        data: {'text': newText},
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to edit message'));
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete(ApiConstants.deleteMessage(messageId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to delete message'));
    }
  }

  Future<void> markRead(String friendId) async {
    try {
      await _dio.post(ApiConstants.chatRead(friendId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to mark as read'));
    }
  }

  // ─── Group chat ────────────────────────────────────────────────────

  /// Returns the raw conversation map (caller parses via ConversationModel.fromApi).
  Future<Map<String, dynamic>> createGroup({
    required String title,
    required List<String> memberIds,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.groups,
        data: {'title': title, 'memberIds': memberIds},
      );
      return Map<String, dynamic>.from(res.data['conversation'] as Map);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to create group'));
    }
  }

  Future<List<MessageModel>> fetchGroupMessages({
    required String conversationId,
    DateTime? before,
    int limit = 30,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.groupMessages(conversationId),
        queryParameters: {
          if (before != null) 'before': before.toIso8601String(),
          'limit': limit,
        },
      );
      final list = (res.data['messages'] as List<dynamic>?) ?? const [];
      return list
          .map((e) => MessageModel.fromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to fetch group messages'));
    }
  }

  Future<MessageModel> sendGroupText({
    required String conversationId,
    required String text,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.groupMessages(conversationId),
        data: {'type': 'text', 'text': text},
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send group message'));
    }
  }

  Future<MessageModel> sendGroupImage({
    required String conversationId,
    required String imagePath,
  }) async {
    try {
      final form = FormData.fromMap({
        'type': 'image',
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(Platform.pathSeparator).last,
        ),
      });
      final res = await _dio.post(
        ApiConstants.groupMessages(conversationId),
        data: form,
      );
      return MessageModel.fromApi(res.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to send group image'));
    }
  }

  Future<void> markGroupRead(String conversationId) async {
    try {
      await _dio.post(ApiConstants.groupRead(conversationId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to mark group as read'));
    }
  }

  Future<Map<String, dynamic>> renameGroup({
    required String conversationId,
    required String title,
  }) async {
    try {
      final res = await _dio.patch(
        ApiConstants.group(conversationId),
        data: {'title': title},
      );
      return Map<String, dynamic>.from(res.data['conversation'] as Map);
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to rename group'));
    }
  }

  Future<void> addGroupMember({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _dio.post(
        ApiConstants.groupMembers(conversationId),
        data: {'userId': userId},
      );
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to add member'));
    }
  }

  Future<void> removeGroupMember({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _dio.delete(ApiConstants.groupMember(conversationId, userId));
    } on DioException catch (e) {
      throw ServerException(_extract(e, 'Failed to remove member'));
    }
  }

  String _extract(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }
}
