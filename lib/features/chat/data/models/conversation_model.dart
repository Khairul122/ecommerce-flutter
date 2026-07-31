import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    super.storeId,
    required super.storeName,
    super.storeImage,
    super.lastMessage,
    super.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>? ?? {};
    final lastMessage = json['last_message'] as Map<String, dynamic>?;
    return ConversationModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      storeId: store['id'] is int
          ? store['id'] as int
          : int.tryParse(store['id']?.toString() ?? ''),
      storeName: store['store_name']?.toString() ?? 'Toko',
      storeImage: store['logo_url']?.toString(),
      lastMessage: lastMessage?['message']?.toString(),
      lastMessageAt: lastMessage?['created_at']?.toString(),
    );
  }
}
