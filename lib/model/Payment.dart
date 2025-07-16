class Payment {
  final int id;
  final int bookingId;
  final String method;
  final String status;
  final DateTime paidAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.method,
    required this.status,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    bookingId: json['booking_id'],
    method: json['method'],
    status: json['status'],
    paidAt: DateTime.parse(json['paid_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'method': method,
    'status': status,
    'paid_at': paidAt.toIso8601String(),
  };
}
