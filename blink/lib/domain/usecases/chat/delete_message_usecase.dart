import '../../repositories/chat_repository.dart';

class DeleteMessageUseCase {
  final ChatRepository repo;
  DeleteMessageUseCase(this.repo);

  Future<void> call(String messageId) => repo.deleteMessage(messageId);
}
