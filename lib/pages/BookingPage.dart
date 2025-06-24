import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedProvince;
  TimeOfDay? selectedTime;
  List<String> provinces = [];
  bool isLoading = true;
  String? errorMessage;

  // Sample user data - in real app, this would come from your backend
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Trang Hoàng',
      'time': const TimeOfDay(hour: 4, minute: 30),
      'avatar': null,
    },
    {
      'name': 'Minh Đức',
      'time': const TimeOfDay(hour: 5, minute: 0),
      'avatar': null,
    },
    {
      'name': 'Thu Hà',
      'time': const TimeOfDay(hour: 6, minute: 30),
      'avatar': null,
    },
    {
      'name': 'Văn Nam',
      'time': const TimeOfDay(hour: 7, minute: 0),
      'avatar': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http
          .get(
            Uri.parse('https://provinces.open-api.vn/api/p/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          provinces = data.map((e) => e['name'].toString()).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải danh sách tỉnh thành: $e';
        isLoading = false;
        // Fallback provinces if API fails
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
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  List<Map<String, dynamic>> getFilteredUsers() {
    return users.where((user) {
      bool matchesTime =
          selectedTime == null ||
          (user['time'] as TimeOfDay).hour == selectedTime!.hour &&
              (user['time'] as TimeOfDay).minute == selectedTime!.minute;
      // In real app, you'd also filter by province
      return matchesTime;
    }).toList();
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
                          : (value) => setState(() => selectedProvince = value),
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
                '${getFilteredUsers().length} người',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Danh sách người dùng
          Expanded(
            child: getFilteredUsers().isEmpty
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
                    itemCount: getFilteredUsers().length,
                    itemBuilder: (context, index) {
                      final user = getFilteredUsers()[index];
                      final time = user['time'] as TimeOfDay;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                              child: user['avatar'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Image.network(
                                        user['avatar'],
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
                              user['name'],
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
                                    formatTimeOfDay(time),
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
                                // Handle menu actions
                                switch (value) {
                                  case 'view':
                                    // View profile action
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
                                      Icon(Icons.person),
                                      SizedBox(width: 8),
                                      Text('Xem hồ sơ'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'message',
                                  child: Row(
                                    children: [
                                      Icon(Icons.message),
                                      SizedBox(width: 8),
                                      Text('Nhắn tin'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(Icons.report),
                                      SizedBox(width: 8),
                                      Text('Báo cáo'),
                                    ],
                                  ),
                                ),
                              ],
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
