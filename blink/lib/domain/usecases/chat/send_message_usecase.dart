import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repo;
  SendMessageUseCase(this.repo);

  Future<MessageEntity> sendText({
    required String friendId,
    required String text,
    required String clientMessageId,
  }) =>
      repo.sendTextMessage(
        friendId: friendId,
        text: text,
        clientMessageId: clientMessageId,
      );

  Future<MessageEntity> sendImage({
    required String friendId,
    required String imagePath,
    required String clientMessageId,
  }) =>
      repo.sendImageMessage(
        friendId: friendId,
        imagePath: imagePath,
        clientMessageId: clientMessageId,
      );
}
