import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

/// Kontrak layer domain untuk fitur chat owner. Implementasinya (data layer)
/// menentukan dari mana data ini datang (REST API).
abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();

  Future<List<MessageEntity>> getMessages(int conversationId);

  Future<void> sendMessage(int conversationId, String message);
}
