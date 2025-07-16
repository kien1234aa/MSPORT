class TimeSlot {
  final int id;
  final int fieldId;
  final String startTime;
  final String endTime;
  final bool available;

  TimeSlot({
    required this.id,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    required this.available,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    id: json['id'],
    fieldId: json['field_id'],
    startTime: json['start_time'],
    endTime: json['end_time'],
    available: json['available'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'field_id': fieldId,
    'start_time': startTime,
    'end_time': endTime,
    'available': available,
  };
}
