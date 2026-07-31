import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_detail_screen.dart';
import 'providers/chat_provider.dart';
import '../domain/entities/conversation_entity.dart';

/// Perbaikan audit: sebelumnya daftar chat adalah array lokal statis (data
/// contoh yang ditulis langsung di kode, tidak pernah berubah), dan search
/// bar di layar ini tidak tersambung ke apa pun (TextField tanpa controller/
/// onChanged). Sekarang memuat percakapan asli dari GET /conversations, dan
/// search bar benar-benar memfilter daftar berdasarkan nama toko.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ConversationEntity> _filtered = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadConversations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    final conversations = context.read<ChatProvider>().conversations;
    setState(() {
      if (query.isEmpty) {
        _filtered = conversations;
      } else {
        _filtered = conversations
            .where((c) => c.storeName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadConversations() async {
    await context.read<ChatProvider>().loadConversations();
    if (mounted) {
      setState(() {
        _filtered = context.read<ChatProvider>().conversations;
      });
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: maroonColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat',
          style: GoogleFonts.outfit(
            color: maroonColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  hintText: 'Cari percakapan...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(maroonColor)),
        ],
      ),
    );
  }

  Widget _buildBody(Color maroonColor) {
    final chatProvider = context.watch<ChatProvider>();
    if (chatProvider.isLoadingConversations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (chatProvider.conversationsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(chatProvider.conversationsError!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _loadConversations, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Text('Belum ada percakapan', style: GoogleFonts.outfit(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filtered.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final chat = _filtered[index];
          final String storeName = chat.storeName;
          final String lastMessageText = chat.lastMessage ?? 'Belum ada pesan';

          return ListTile(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    conversationId: chat.id.toString(),
                    storeName: storeName,
                  ),
                ),
              );
              _loadConversations();
            },
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            title: Text(
              storeName,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
            ),
            subtitle: Text(
              lastMessageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
