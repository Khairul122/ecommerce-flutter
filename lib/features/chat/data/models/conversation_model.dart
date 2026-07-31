import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.userName,
    required super.lastMessage,
    super.lastMessageAt,
    required super.raw,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final lastMessage = json['last_message'] as Map<String, dynamic>?;
    return ConversationModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      userName: (user?['name'] as String?) ?? 'Pembeli',
      lastMessage: (lastMessage?['message'] as String?) ?? 'Belum ada pesan',
      lastMessageAt: DateTime.tryParse(
        (lastMessage?['created_at'] as String?) ?? '',
      ),
      raw: json,
    );
  }
}
