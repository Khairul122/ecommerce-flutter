import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/chat_usecases.dart';

/// State chat (daftar percakapan + thread pesan aktif), dibaca lewat
/// `context.watch<ChatProvider>()` / `context.read<ChatProvider>()`.
/// Menggantikan pemanggilan `ApiService()` langsung dari layar.
class ChatProvider extends ChangeNotifier {
  final GetConversationsUseCase getConversationsUseCase;
  final StartConversationUseCase startConversationUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatProvider({
    required this.getConversationsUseCase,
    required this.startConversationUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  });

  List<ConversationEntity> _conversations = [];
  bool _isLoadingConversations = false;
  String? _conversationsError;

  List<MessageEntity> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _messagesError;

  List<ConversationEntity> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get conversationsError => _conversationsError;

  List<MessageEntity> get messages => _messages;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get messagesError => _messagesError;

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _conversationsError = null;
    notifyListeners();
    try {
      _conversations = await getConversationsUseCase(const NoParams());
    } catch (e) {
      _conversationsError = 'Gagal memuat percakapan: $e';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<ConversationEntity> startConversation(int storeId) async {
    final conversation = await startConversationUseCase(storeId);
    return conversation;
  }

  Future<void> loadMessages(int conversationId, {bool showSpinner = true}) async {
    if (showSpinner) {
      _isLoadingMessages = true;
      notifyListeners();
    }
    _messagesError = null;
    try {
      _messages = await getMessagesUseCase(conversationId);
    } catch (e) {
      _messagesError = 'Gagal memuat pesan: $e';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(int conversationId, String message) async {
    _isSendingMessage = true;
    notifyListeners();
    try {
      final sent = await sendMessageUseCase(
        SendMessageParams(conversationId: conversationId, message: message),
      );
      _messages = [..._messages, sent];
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages = [];
    _messagesError = null;
  }
}
