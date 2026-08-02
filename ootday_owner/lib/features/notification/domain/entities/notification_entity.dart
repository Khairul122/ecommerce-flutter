class NotificationEntity {
  final int id;
  final String title;
  final String body;
  final String? type;
  final int? relatedId;
  final bool isRead;
  final String? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.relatedId,
    required this.isRead,
    this.createdAt,
  });
}
