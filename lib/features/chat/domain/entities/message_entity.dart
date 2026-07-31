class MessageEntity {
  final int id;
  final int conversationId;
  final String senderType;
  final String message;
  final String? createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.message,
    this.createdAt,
  });

  bool get isMe => senderType == 'user';
}
