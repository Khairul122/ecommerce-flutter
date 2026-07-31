import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.message,
    required super.senderType,
    super.createdAt,
    super.isRead,
    required super.raw,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      message: (json['message'] as String?) ?? '',
      senderType: (json['sender_type'] as String?) ?? '',
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? ''),
      isRead: (json['is_read'] as bool?) ?? false,
      raw: json,
    );
  }
}
