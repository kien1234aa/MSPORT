import 'package:flutter/material.dart';
import 'package:msport/model/sport_field.dart';

class BookingCard extends StatelessWidget {
  final SportsField field;
  final VoidCallback onCancel;

  const BookingCard({Key? key, required this.field, required this.onCancel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            field.imgUrl.isNotEmpty
                ? field.imgUrl
                : 'https://th.bing.com/th/id/R.558d9ec0b82b770e0066afaa1c95d530?rik=kdNRHXhgmfNspQ&pid=ImgRaw&r=0',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(field.name),
        subtitle: Text('${field.location}\n${field.time}'),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: onCancel,
        ),
      ),
    );
  }
}
