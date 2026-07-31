import '../../../../core/usecase.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase extends UseCase<List<ConversationEntity>, NoParams> {
  final ChatRepository repository;
  GetConversationsUseCase(this.repository);

  @override
  Future<List<ConversationEntity>> call(NoParams params) =>
      repository.getConversations();
}

class GetMessagesUseCase extends UseCase<List<MessageEntity>, int> {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  @override
  Future<List<MessageEntity>> call(int conversationId) =>
      repository.getMessages(conversationId);
}

class SendMessageParams {
  final int conversationId;
  final String message;
  const SendMessageParams({required this.conversationId, required this.message});
}

class SendMessageUseCase extends UseCase<void, SendMessageParams> {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  @override
  Future<void> call(SendMessageParams params) =>
      repository.sendMessage(params.conversationId, params.message);
}
