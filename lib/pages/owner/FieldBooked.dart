import 'package:flutter/material.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/widget/BookedCard.dart';

class FieldBooked extends StatefulWidget {
  const FieldBooked({super.key});

  @override
  State<FieldBooked> createState() => _FieldBookedState();
}

class _FieldBookedState extends State<FieldBooked> {
  late Future<List<SportsField>> _futureField;
  DBUser dbUser = DBUser();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final currentUserId = await dbUser.getCurrentUserId();

    setState(() {
      _futureField = dbUser.getFieldBooked(currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD4F4E7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sân khách đặt:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<SportsField>>(
              future: _futureField,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final listBooking = snapshot.data ?? [];

                if (listBooking.isEmpty) {
                  return const Center(
                    child: Text('Chưa có khách nào đặt sân.'),
                  );
                }

                return ListView.builder(
                  itemCount: listBooking.length,
                  itemBuilder: (context, index) {
                    final booking = listBooking[index];
                    return BookingCard(
                      field: booking, // Use the booking object directly
                      onCancel: () {
                        // Add your cancel logic here
                        // You might want to refresh the data after cancelling
                        _loadData();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
