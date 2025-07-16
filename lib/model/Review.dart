class Review {
  final int id;
  final int userId;
  final int fieldId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    userId: json['user_id'],
    fieldId: json['field_id'],
    rating: json['rating'],
    comment: json['comment'],
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'field_id': fieldId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
  };
}
