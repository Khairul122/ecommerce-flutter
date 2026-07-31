import '../../../../core/services/api_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur chat. Tidak menyimpan
/// state apa pun — murni pemanggilan endpoint dan parsing response.
class ChatRemoteDataSource {
  final ApiService _api;
  ChatRemoteDataSource(this._api);

  Future<List<ConversationModel>> getConversations() async {
    final result = await _api.get('/conversations');
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationModel> startConversation(int storeId) async {
    final result = await _api.post('/conversations', {'store_id': storeId});
    final data = Map<String, dynamic>.from(result['data'] ?? {});
    return ConversationModel.fromJson(data);
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    final result = await _api.get('/conversations/$conversationId/messages');
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageModel> sendMessage(int conversationId, String message) async {
    final result = await _api.post(
      '/conversations/$conversationId/messages',
      {'message': message},
    );
    final data = Map<String, dynamic>.from(result['data'] ?? {});
    return MessageModel.fromJson(data);
  }
}
