// blink/lib/presentation/providers/chat_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/api_chat_datasource.dart';
import '../../data/datasources/remote/socket_chat_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/chat/delete_message_usecase.dart';
import '../../domain/usecases/chat/edit_message_usecase.dart';
import '../../domain/usecases/chat/mark_as_read_usecase.dart';
import '../../domain/usecases/chat/send_message_usecase.dart';
import 'auth_provider.dart';
import 'socket_provider.dart';

final apiChatDatasourceProvider = Provider<ApiChatDatasource>((ref) {
  return ApiChatDatasource(ref.watch(apiClientProvider));
});

final socketChatDatasourceProvider = Provider<SocketChatDatasource>((ref) {
  final socket = ref.watch(socketProvider);
  final ds = SocketChatDatasource(socket);
  ref.onDispose(ds.dispose);
  return ds;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) {
    throw StateError('chatRepositoryProvider requires an authenticated user');
  }
  final repo = ChatRepositoryImpl(
    api: ref.watch(apiChatDatasourceProvider),
    socket: ref.watch(socketChatDatasourceProvider),
    currentUserId: uid,
  );
  ref.onDispose(repo.dispose);
  return repo;
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final editMessageUseCaseProvider = Provider<EditMessageUseCase>((ref) {
  return EditMessageUseCase(ref.watch(chatRepositoryProvider));
});

final deleteMessageUseCaseProvider = Provider<DeleteMessageUseCase>((ref) {
  return DeleteMessageUseCase(ref.watch(chatRepositoryProvider));
});

final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  return MarkAsReadUseCase(ref.watch(chatRepositoryProvider));
});

final conversationsProvider =
    StreamProvider<Map<String, ConversationEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchConversations().map(
        (list) => {for (final c in list) c.otherUserId: c},
      );
});

final messagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, friendId) {
  return ref.watch(chatRepositoryProvider).watchMessages(friendId);
});

final typingProvider =
    StreamProvider.family<bool, String>((ref, friendId) {
  return ref.watch(chatRepositoryProvider).watchTyping(friendId);
});

// ─── Group chat providers ──────────────────────────────────────────

final groupsProvider = StreamProvider<List<ConversationEntity>>((ref) {
  return ref.watch(chatRepositoryProvider).watchGroups();
});

final groupMessagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).watchGroupMessages(conversationId);
});
