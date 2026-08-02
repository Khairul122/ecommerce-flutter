import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';

/// Perbaikan audit: sebelumnya seluruh percakapan hanya disimpan di
/// `_messages` (List lokal di memori), jadi pesan hilang begitu layar
/// ditutup dan tidak pernah benar-benar terkirim ke siapa pun. Sekarang
/// memakai GET/POST /conversations/{id}/messages sungguhan.
class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String storeName;
  const ChatDetailScreen({super.key, required this.conversationId, required this.storeName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollTimer;
  int _lastMessageCount = 0;

  int get _conversationId => int.tryParse(widget.conversationId) ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMessages());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadMessages(showSpinner: false),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool showSpinner = true}) async {
    await context.read<ChatProvider>().loadMessages(_conversationId, showSpinner: showSpinner);
    if (mounted) {
      final newCount = context.read<ChatProvider>().messages.length;
      if (newCount > _lastMessageCount) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      _lastMessageCount = newCount;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final chatProvider = context.read<ChatProvider>();
    if (text.isEmpty || chatProvider.isSendingMessage) return;

    try {
      await chatProvider.sendMessage(_conversationId, text);
      if (mounted) {
        _messageController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim pesan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color maroonColor = Color(0xFF5D1A1A);
    const Color bgColor = Color(0xFFF8F3F3);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.storeName,
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(maroonColor)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Builder(builder: (context) {
                  final isSending = context.watch<ChatProvider>().isSendingMessage;
                  return GestureDetector(
                    onTap: isSending ? null : _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: maroonColor,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(Color maroonColor) {
    final chatProvider = context.watch<ChatProvider>();
    if (chatProvider.isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chatProvider.messagesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(chatProvider.messagesError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadMessages, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    final messages = chatProvider.messages;
    if (messages.isEmpty) {
      return Center(
        child: Text('Mulai percakapan dengan mengirim pesan', style: GoogleFonts.outfit(color: Colors.grey)),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final String time = _formatTime(msg.createdAt);
        return _buildChatBubble(msg.message, msg.isMe, time, maroonColor);
      },
    );
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } catch (_) {
      return '';
    }
  }

  Widget _buildChatBubble(String text, bool isMe, String time, Color maroonColor) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: isMe ? maroonColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: Radius.circular(isMe ? 15 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
