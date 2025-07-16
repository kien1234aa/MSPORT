import 'package:flutter/material.dart';
import 'package:msport/model/sport_field.dart';

class FieldBookedCard extends StatelessWidget {
  final SportsField field;
  final String bookingStatus;
  final VoidCallback onCancel;

  const FieldBookedCard({
    super.key,
    required this.field,
    required this.bookingStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFF1FAF0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Sân của bạn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: field.imgUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(field.imgUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: field.imgUrl.isEmpty
                  ? const Icon(Icons.image, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: "Tên sân: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: field.name),
                    ],
                  ),
                ),
                Text("Khung giờ: ${field.time}"),
                Text("Vị trí: ${field.location}"),
                Text("Chủ sân (ID): ${field.ownerId}"),
                Text("Mô tả: ${field.description}"),
                Text("Giá/giờ: ${field.pricePerHour.toStringAsFixed(0)}đ"),
                const SizedBox(height: 4),
                Text(
                  "Trạng thái: $bookingStatus",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Huỷ đặt sân"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
