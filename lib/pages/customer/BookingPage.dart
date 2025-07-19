import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/Notification.dart';
import 'package:msport/model/bookings.dart';

import 'package:msport/model/sport_field.dart';
import 'package:msport/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingPage extends StatefulWidget {
  final User1? user;
  const BookingPage({super.key, required this.user});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedProvince;
  TimeOfDay? selectedTime;
  List<String> provinces = [];
  bool isLoading = true;
  String? errorMessage;
  List<SportsField> sportFields = [];
  late Future<String> nameUserFuture;

  String encodeSpacesOnly(String input) {
    return Uri.encodeComponent(input);
  }

  Future<void> fetchAllSportFields() async {
    if (selectedProvince == null || selectedTime == null) return;

    final location = encodeSpacesOnly(selectedProvince!);
    final time = formatTimeOfDay(selectedTime!);

    final url =
        'https://aejmidrpergglildqomq.supabase.co/rest/v1/sports_fields?location=eq.$location&time=eq.$time&status=eq.active';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'apikey':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFlam1pZHJwZXJnZ2xpbGRxb21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mzc0ODMsImV4cCI6MjA2NTIxMzQ4M30.sbPFjcJjRahLqr-lh0Gk9ksIBHRSwXuV0Od5KeM4xlc',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFlam1pZHJwZXJnZ2xpbGRxb21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2Mzc0ODMsImV4cCI6MjA2NTIxMzQ4M30.sbPFjcJjRahLqr-lh0Gk9ksIBHRSwXuV0Od5KeM4xlc',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          sportFields = data.map((e) => SportsField.fromJson(e)).toList();
        });
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Failed to load sport fields');
      }
    } catch (e) {
      print('Error fetching sport fields: $e');
    }
  }

  Future<void> insertBooking(int index) async {
    final data = await DBUser().getCurrentUserData();

    if (data != null) {
      final field = sportFields[index];

      Booking booking = Booking(
        userId: data['id'],
        fieldId: field.id!,
        date: DateTime.now(), // Ngày đặt sân
        totalPrice: field.pricePerHour,
        status: "pending",
        createdAt: DateTime.now(),
      );

      await DBUser().createBooking(booking);
    } else {
      throw Exception('Không tìm thấy thông tin người dùng');
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    fetchProvinces();
    nameUserFuture = DBUser().getNameCurrent();
  }

  Future<void> fetchProvinces() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Create HTTP client that accepts bad certificates
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      final client = IOClient(httpClient);

      final response = await client.get(
        Uri.parse('https://provinces.open-api.vn/api/p/'),
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Debug: xem cấu trúc JSON

        final json = jsonDecode(response.body);

        // Kiểm tra cấu trúc JSON và xử lý accordingly
        List<dynamic> data;

        if (json is List) {
          // Nếu response là array trực tiếp
          data = json;
        } else if (json is Map && json.containsKey('results')) {
          // Nếu response có key 'results'
          data = json['results'] as List;
        } else if (json is Map && json.containsKey('data')) {
          // Nếu response có key 'data'
          data = json['data'] as List;
        } else {
          throw Exception('Unknown JSON structure');
        }

        setState(() {
          provinces = data.map((e) {
            // Kiểm tra các key có thể có trong object
            if (e is Map) {
              return e['province_name']?.toString() ??
                  e['name']?.toString() ??
                  e['province']?.toString() ??
                  'Unknown';
            }
            return e.toString();
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Debug
      setState(() {
        errorMessage = 'Không thể tải danh sách tỉnh thành: $e';
        isLoading = false;
        provinces = [
          'Hà Nội',
          'Hồ Chí Minh',
          'Đà Nẵng',
          'Hải Phòng',
          'Cần Thơ',
          'An Giang',
          'Bà Rịa - Vũng Tàu',
        ];
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });

      await fetchAllSportFields();
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  //dialog cofirm booking
  void showCustomDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bạn có muốn đặt sân này không',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop(true);

                        final field = sportFields[index];

                        if (field.id != null) {
                          await DBUser().updateItemStatusToUnactive(field.id!);

                          await DBUser().bookFieldAndNotify(
                            fieldId: field.id!,
                            pricePerHour: field.pricePerHour,
                            time: field.time,
                          );

                          setState(() {
                            sportFields.removeAt(index);
                          });
                        } else {
                          print('Error: field.id is null');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Có',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Xử lý khi nhấn Không
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Không',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Error message
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ),

          // Dropdowns
          Column(
            children: [
              // Tỉnh thành
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bạn đang ở đâu',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      value: selectedProvince,
                      hint: const Text('Chọn tỉnh thành'),
                      isExpanded: true,
                      items: isLoading
                          ? [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Đang tải...'),
                              ),
                            ]
                          : provinces.map((province) {
                              return DropdownMenuItem(
                                value: province,
                                child: Text(
                                  province,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() {
                                selectedProvince = value;
                              });
                              if (selectedProvince != null &&
                                  selectedTime != null) {
                                fetchAllSportFields();
                              }
                            },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Khung giờ - Time Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khung giờ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedTime != null
                                  ? formatTimeOfDay(selectedTime!)
                                  : 'Chọn giờ',
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedTime != null
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filter info
          Row(
            children: [
              Text(
                'Danh sách người dùng',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${sportFields.length} người',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Danh sách người dùng
          Expanded(
            child: sportFields.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có sân này',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thử thay đổi bộ lọc của bạn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: sportFields.length,
                    itemBuilder: (context, index) {
                      final field = sportFields[index];
                      final time = sportFields[index].time;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            showCustomDialog(context, index);
                          },
                          child: Card(
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: sportFields[index].imgUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Image.network(
                                          sportFields[index].imgUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 28,
                                                  color: Colors.blue.shade600,
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 28,
                                        color: Colors.blue.shade600,
                                      ),
                              ),
                              title: Text(
                                sportFields[index].name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  // Handle menu item selection
                                  switch (value) {
                                    case 'view':
                                      break;
                                    case 'message':
                                      // Send message action
                                      break;
                                    case 'report':
                                      // Report user action
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Text('Xem thông tin sân'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'message',
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Text('Nhắn tin với chủ sân'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Text('Báo cáo'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
