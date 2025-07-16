class BookingDetail {
  final String? fieldName;
  final String? fieldImg;
  final String? time;
  final String? customerName;
  final DateTime? date;
  final double? totalPrice;

  BookingDetail({
    this.fieldName,
    this.fieldImg,
    this.time,
    this.customerName,
    this.date,
    this.totalPrice,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      fieldName: json['sports_fields']['name'],
      fieldImg: json['sports_fields']['img_url'],
      time: json['time_slots']['time'],
      customerName: json['users']['full_name'],
      date: DateTime.tryParse(json['date']),
      totalPrice: json['total_price']?.toDouble(),
    );
  }
}
