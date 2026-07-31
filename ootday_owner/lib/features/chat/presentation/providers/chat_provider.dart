import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/chat_usecases.dart';

/// State chat owner, dibaca lewat `context.watch<ChatProvider>()` /
/// `context.read<ChatProvider>()`. Menggantikan pemanggilan `ApiService()`
/// langsung dari widget chat.
class ChatProvider extends ChangeNotifier {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatProvider({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  });

  List<ConversationEntity> _conversations = [];
  bool _isLoadingConversations = false;
  String? _conversationsError;

  List<MessageEntity> _messages = [];
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _messagesError;

  List<ConversationEntity> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get conversationsError => _conversationsError;

  List<MessageEntity> get messages => _messages;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get messagesError => _messagesError;

  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    _conversationsError = null;
    notifyListeners();
    try {
      _conversations = await getConversationsUseCase(const NoParams());
    } catch (e) {
      _conversationsError = '$e';
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(int conversationId, {bool showSpinner = true}) async {
    if (showSpinner) {
      _isLoadingMessages = true;
      notifyListeners();
    }
    try {
      _messages = await getMessagesUseCase(conversationId);
      _messagesError = null;
    } catch (e) {
      _messagesError = '$e';
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Melempar exception jika gagal supaya layar bisa menampilkan snackbar,
  /// sama seperti perilaku sebelumnya.
  Future<void> sendMessage(int conversationId, String message) async {
    _isSending = true;
    notifyListeners();
    try {
      await sendMessageUseCase(
        SendMessageParams(conversationId: conversationId, message: message),
      );
      await loadMessages(conversationId, showSpinner: false);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
