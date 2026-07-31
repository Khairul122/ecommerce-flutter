import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Kontrak layer domain untuk fitur chat. Implementasinya (data layer)
/// berbicara ke REST API `/conversations` (lihat API_CONTRACT.md).
abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();

  Future<ConversationEntity> startConversation(int storeId);

  Future<List<MessageEntity>> getMessages(int conversationId);

  Future<MessageEntity> sendMessage(int conversationId, String message);
}
