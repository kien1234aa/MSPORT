import 'package:flutter/material.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/Notification.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/widget/BookedCard.dart';

class FieldBooked extends StatefulWidget {
  const FieldBooked({super.key});

  @override
  State<FieldBooked> createState() => _FieldBookedState();
}

class _FieldBookedState extends State<FieldBooked> {
  late Future<List<SportsField>> _futureField;
  List<NotificationModel>? _listNotification;
  DBUser dbUser = DBUser();

  @override
  void initState() {
    super.initState();
    _loadData();
    fetchNotifications();
  }

  void _loadData() async {
    final currentUserId = await dbUser.getCurrentUserId();

    setState(() {
      _futureField = dbUser.getFieldBooked(currentUserId);
    });
  }

  Future<void> fetchNotifications() async {
    _listNotification = await DBUser().getNotificationsForCurrentUser();
    setState(() {});
  }

  void showCustomNotificationDialog(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thông báo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Column(
                  children: notifications.map((noti) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              noti.content,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFD4F4E7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sân khách đặt:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              StreamBuilder<int>(
                stream: Stream.periodic(
                  Duration(seconds: 3),
                ).asyncMap((_) => DBUser().countUnreadNotifications()),
                builder: (context, snapshot) {
                  int count = snapshot.data ?? 0;
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          setState(() {
                            count = 0;
                          });
                          showCustomNotificationDialog(
                            context,
                            _listNotification!,
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
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
