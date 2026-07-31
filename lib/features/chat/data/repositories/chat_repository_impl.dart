import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

/// Implementasi [ChatRepository]: mengoordinasikan remote data source
/// (REST API) untuk fitur chat owner.
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl({required this.remote});

  @override
  Future<List<ConversationEntity>> getConversations() => remote.getConversations();

  @override
  Future<List<MessageEntity>> getMessages(int conversationId) =>
      remote.getMessages(conversationId);

  @override
  Future<void> sendMessage(int conversationId, String message) =>
      remote.sendMessage(conversationId, message);
}
