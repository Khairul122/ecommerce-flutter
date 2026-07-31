import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderType,
    required super.message,
    super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      conversationId: json['conversation_id'] is int
          ? json['conversation_id'] as int
          : int.tryParse(json['conversation_id']?.toString() ?? '') ?? 0,
      senderType: json['sender_type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}
