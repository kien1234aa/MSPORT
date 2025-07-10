import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:msport/model/sport_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateFieldDialogContent extends StatefulWidget {
  final void Function()? onFieldCreated;
  const CreateFieldDialogContent({super.key, this.onFieldCreated});

  @override
  State<CreateFieldDialogContent> createState() =>
      _CreateFieldDialogContentState();
}

class _CreateFieldDialogContentState extends State<CreateFieldDialogContent> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  int selectedTypeField = 5;
  TimeOfDay selectedTime = TimeOfDay.now();

  String? selectedProvince;
  List<String> provinceList = [];
  bool isLoadingProvinces = true;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  // load provinces from API
  Future<void> fetchProvinces() async {
    try {
      final response = await http.get(
        Uri.parse('https://provinces.open-api.vn/api/p/'),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          provinceList = data.map<String>((e) => e['name'].toString()).toList();
          isLoadingProvinces = false;
        });
      } else {
        throw Exception("Lỗi tải tỉnh thành");
      }
    } catch (e) {
      print("Lỗi khi fetch tỉnh thành: $e");
      setState(() {
        isLoadingProvinces = false;
      });
    }
  }

  // Create a new sport field
  Future<String?> createSportField(SportField field) async {
    final user = supabase.auth.currentUser;
    if (user == null) return "Bạn chưa đăng nhập.";

    final authUserId = user.id;

    try {
      final userResponse = await supabase
          .from('users')
          .select('id, role')
          .eq('auth_id', authUserId)
          .maybeSingle();

      if (userResponse == null) return "Không tìm thấy người dùng.";
      if (userResponse['role'] != 'owner') return "Bạn không có quyền tạo sân.";

      final ownerId = userResponse['id'];
      await supabase.from('sports_fields').insert({
        ...field.toJson(),
        'owner_id': ownerId,
      });

      return null;
    } catch (e) {
      return "Lỗi khi tạo sân: $e";
    }
  }

  // Select time using
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tạo sân:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'add image',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 15),
            _buildTextField(hint: 'Name', controller: nameController),
            const SizedBox(height: 10),

            // Dropdown chọn tỉnh/thành
            isLoadingProvinces
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: selectedProvince,
                    items: provinceList.map((province) {
                      return DropdownMenuItem(
                        value: province,
                        child: Text(province),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text("Chọn tỉnh/thành"),
                  ),
            const SizedBox(height: 10),

            _buildTextField(hint: 'Price', controller: priceController),
            const SizedBox(height: 10),

            InkWell(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.access_time, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<int>(
              value: selectedTypeField,
              items: [5, 7, 11].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTypeField = value;
                  });
                }
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            _buildTextField(
              hint: 'Description',
              maxLines: 3,
              controller: descriptionController,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () async {
                  final newField = SportField(
                    name: nameController.text.trim(),
                    location: selectedProvince ?? '',
                    description: descriptionController.text.trim(),
                    pricePerHour:
                        double.tryParse(priceController.text.trim()) ?? 0.0,
                    ownerId: 0,
                    status: 'active',
                    type: selectedTypeField,
                    imgURL: '',
                    time:
                        '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  );

                  final error = await createSportField(newField);
                  if (error != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error)));
                  } else {
                    Navigator.of(context).pop();
                    widget.onFieldCreated?.call();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tạo sân thành công!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Tạo Sân',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
