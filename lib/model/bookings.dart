class Booking {
  final int? userId;
  final int? fieldId;
  final int? timeSlotId;
  final DateTime? date;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;

  Booking({
    this.userId,
    this.fieldId,
    this.timeSlotId,
    this.date,
    this.totalPrice,
    this.status,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      userId: json['user_id'],
      fieldId: json['field_id'],
      timeSlotId: json['time_slot_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      totalPrice: json['total_price']?.toDouble(),
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'field_id': fieldId,
      'date': date?.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
