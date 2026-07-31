/// Satu percakapan owner dengan pembeli (ringkasan untuk daftar chat).
class ConversationEntity {
  final int id;
  final String userName;
  final String lastMessage;
  final DateTime? lastMessageAt;

  /// JSON mentah dari server, dipertahankan untuk field yang belum
  /// dimodelkan secara eksplisit di sini.
  final Map<String, dynamic> raw;

  const ConversationEntity({
    required this.id,
    required this.userName,
    required this.lastMessage,
    this.lastMessageAt,
    required this.raw,
  });
}
