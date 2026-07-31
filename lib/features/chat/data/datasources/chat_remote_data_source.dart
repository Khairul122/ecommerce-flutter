import '../../../../core/services/api_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur chat owner.
class ChatRemoteDataSource {
  final ApiService _api;
  ChatRemoteDataSource(this._api);

  Future<List<ConversationModel>> getConversations() async {
    final res = await _api.get('/conversations');
    final data = res['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(ConversationModel.fromJson)
        .toList();
  }

  Future<List<MessageModel>> getMessages(int conversationId) async {
    final res = await _api.get('/conversations/$conversationId/messages');
    final data = res['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>().map(MessageModel.fromJson).toList();
  }

  Future<void> sendMessage(int conversationId, String message) {
    return _api.post(
      '/conversations/$conversationId/messages',
      {'message': message},
    );
  }
}
