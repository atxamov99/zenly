import '../../entities/message_entity.dart';
import '../../repositories/chat_repository.dart';

class EditMessageUseCase {
  final ChatRepository repo;
  EditMessageUseCase(this.repo);

  Future<MessageEntity> call({
    required String messageId,
    required String newText,
  }) =>
      repo.editMessage(messageId: messageId, newText: newText);
}
