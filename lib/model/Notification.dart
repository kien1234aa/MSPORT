class NotificationModel {
  final String? id;
  final String title;
  final String content;
  final bool readnoti;
  final DateTime createdAt;
  final String senderId;
  final String receiverId;
  final String type;

  NotificationModel({
    this.id,
    required this.title,
    required this.content,
    required this.readnoti,
    required this.createdAt,
    required this.senderId,
    required this.receiverId,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      readnoti: json['readnoti'],
      createdAt: DateTime.parse(json['created_at']),
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'readnoti': readnoti,
      'created_at': createdAt.toIso8601String(),
      'sender_id': senderId,
      'receiver_id': receiverId,
      'type': type,
    };
  }
}
