import 'package:flutter/material.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/widget/FieldBooked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookedPage extends StatefulWidget {
  const BookedPage({super.key});

  @override
  State<BookedPage> createState() => _BookedPageState();
}

class _BookedPageState extends State<BookedPage> {
  late Future<List<Map<String, dynamic>>> _futureBookings;

  @override
  void initState() {
    super.initState();
    _futureBookings = DBUser().getBookedFieldsByUser("user_id");
  }

  Future<void> cancelBooking(int bookingId, int fieldId) async {
    try {
      final client = Supabase.instance.client;

      // 1. Xoá booking
      await client.from('bookings').delete().eq('id', bookingId);

      // 2. Cập nhật trạng thái sân
      await client
          .from('sports_fields')
          .update({'status': 'active'})
          .eq('id', fieldId);

      // 3. Hiện thông báo và reload lại
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Huỷ đặt sân thành công')));

      setState(() {
        _futureBookings = DBUser().getBookedFieldsByUser("user_id");
      });
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
                return const Center(child: Text('Bạn chưa đặt sân nào.'));
              }

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final field = booking['sports_fields'];

                  return FieldBookedCard(
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
                    bookingStatus: booking['status'] ?? '',
                    onCancel: () {
                      final bookingId = booking['id'];
                      final fieldId = field['id'];
                      cancelBooking(bookingId, fieldId);
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
