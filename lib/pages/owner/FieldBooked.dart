import 'package:flutter/material.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/widget/BookedCard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FieldBooked extends StatefulWidget {
  const FieldBooked({Key? key}) : super(key: key);

  @override
  State<FieldBooked> createState() => _FieldBookedState();
}

class _FieldBookedState extends State<FieldBooked> {
  late Future<List<Map<String, dynamic>>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _futureBookings = DBUser().getBookingsByOwner();
    });
  }

  Future<void> cancelBooking(int bookingId, int fieldId) async {
    try {
      final client = Supabase.instance.client;

      await client.from('bookings').delete().eq('id', bookingId);
      await client
          .from('sports_fields')
          .update({'status': 'active'})
          .eq('id', fieldId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Huỷ đặt sân thành công')));

      _loadBookings();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi huỷ đặt sân: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Sân đã đặt",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureBookings,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }

              final bookings = snapshot.data!;
              if (bookings.isEmpty) {
                return const Center(child: Text('Khách chưa đặt sân nào.'));
              }

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final field = booking['sports_fields'];

                  return BookingCard(
                    field: SportField(
                      id: field['id'],
                      name: field['name'] ?? '',
                      imgURL: field['imgURL'] ?? '',
                      time: booking['time'] ?? '',
                      location: field['location'] ?? '',
                      ownerId: field['owner_id'],
                      description: field['description'] ?? '',
                      type: field['type'] ?? '',
                      pricePerHour: field['price_per_hour']?.toDouble() ?? 0,
                      status: field['status'] ?? 'inactive',
                    ),
                    onCancel: () {
                      cancelBooking(booking['id'], field['id']);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
