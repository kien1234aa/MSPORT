class SportsField {
  final int? id;
  final String imgUrl;
  final int type;
  final String name;
  final String location;
  final String description;
  final int ownerId;
  final double pricePerHour;
  final String status;
  final String time;

  SportsField({
    this.id,
    required this.imgUrl,
    required this.type,
    required this.name,
    required this.location,
    required this.description,
    required this.ownerId,
    required this.pricePerHour,
    required this.status,
    required this.time,
  });

  factory SportsField.fromJson(Map<String, dynamic> json) => SportsField(
    id: json['id'],
    imgUrl: json['imgURL'],
    type: json['type'],
    name: json['name'],
    location: json['location'],
    description: json['description'],
    ownerId: json['owner_id'],
    pricePerHour: (json['price_per_hour'] as num).toDouble(),
    status: json['status'],
    time: json['time'],
  );

  Map<String, dynamic> toJson() => {
    'imgURL': imgUrl,
    'type': type,
    'name': name,
    'location': location,
    'description': description,
    'owner_id': ownerId,
    'price_per_hour': pricePerHour,
    'status': status,
    'time': time,
  };
}
