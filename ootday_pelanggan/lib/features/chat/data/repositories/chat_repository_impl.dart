import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  ChatRepositoryImpl({required this.remote});

  @override
  Future<List<ConversationEntity>> getConversations() => remote.getConversations();

  @override
  Future<ConversationEntity> startConversation(int storeId) =>
      remote.startConversation(storeId);

  @override
  Future<List<MessageEntity>> getMessages(int conversationId) =>
      remote.getMessages(conversationId);

  @override
  Future<MessageEntity> sendMessage(int conversationId, String message) =>
      remote.sendMessage(conversationId, message);
}
