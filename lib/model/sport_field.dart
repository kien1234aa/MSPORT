class SportField {
  final int? id;
  final String name;
  final String location;
  final String description;
  final int type;
  final int ownerId;
  final double pricePerHour;
  final String status;
  final String imgURL;
  final String time; // ✅ Cho phép null

  SportField({
    this.id, // Thêm id với giá trị mặc định
    required this.name,
    required this.location,
    required this.description,
    required this.type,
    required this.ownerId,
    required this.pricePerHour,
    required this.status,
    required this.imgURL,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'description': description,
    'type': type,
    'owner_id': ownerId,
    'price_per_hour': pricePerHour,
    'status': status,
    'imgURL': imgURL,
    'time': time, // Có thể null
  };

  factory SportField.fromJson(Map<String, dynamic> json) {
    return SportField(
      id: json['id'], // Thêm id với giá trị mặc định
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      imgURL: json['imgURL'] ?? '',
      time: json['time'],
    );
  }
}
