class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String content;
  final bool readNoti;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.readNoti,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        userId: json['user_id'],
        title: json['title'],
        content: json['content'],
        readNoti: json['readnoti'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'content': content,
    'readnoti': readNoti,
    'created_at': createdAt.toIso8601String(),
  };
}
