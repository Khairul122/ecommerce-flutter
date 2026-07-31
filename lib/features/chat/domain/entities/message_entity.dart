/// Satu pesan dalam thread percakapan.
class MessageEntity {
  final int id;
  final String message;
  final String senderType;
  final DateTime? createdAt;
  final bool isRead;

  /// JSON mentah dari server, dipertahankan untuk field yang belum
  /// dimodelkan secara eksplisit di sini.
  final Map<String, dynamic> raw;

  const MessageEntity({
    required this.id,
    required this.message,
    required this.senderType,
    this.createdAt,
    this.isRead = false,
    required this.raw,
  });

  /// Owner mengirim pesan ini (dipakai untuk menentukan bubble kanan/kiri).
  bool get isFromStore => senderType == 'store';
}
