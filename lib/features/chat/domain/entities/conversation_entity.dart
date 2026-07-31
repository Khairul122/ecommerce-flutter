class ConversationEntity {
  final int id;
  final int? storeId;
  final String storeName;
  final String? storeImage;
  final String? lastMessage;
  final String? lastMessageAt;

  const ConversationEntity({
    required this.id,
    this.storeId,
    required this.storeName,
    this.storeImage,
    this.lastMessage,
    this.lastMessageAt,
  });
}
