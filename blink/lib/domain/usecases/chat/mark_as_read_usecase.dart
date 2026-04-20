import '../../repositories/chat_repository.dart';

class MarkAsReadUseCase {
  final ChatRepository repo;
  MarkAsReadUseCase(this.repo);

  Future<void> call(String friendId) => repo.markAsRead(friendId);
}
