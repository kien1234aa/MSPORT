import 'package:flutter/material.dart';
import 'package:msport/model/sport_field.dart';

class BookingCard extends StatelessWidget {
  final SportField field;
  final VoidCallback onCancel;

  const BookingCard({Key? key, required this.field, required this.onCancel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.network(
          field.imgURL,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(field.name),
        subtitle: Text('${field.location}\n${field.time}'),
        trailing: IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: onCancel,
        ),
      ),
    );
  }
}
