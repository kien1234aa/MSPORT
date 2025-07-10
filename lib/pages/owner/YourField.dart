import 'package:flutter/material.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/widget/CreateFieldDialogContent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class YourFieldsPage extends StatefulWidget {
  const YourFieldsPage({super.key});

  @override
  State<YourFieldsPage> createState() => _YourFieldsPageState();
}

class _YourFieldsPageState extends State<YourFieldsPage> {
  Future<List<SportField>> fetchAllSportFields() async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      print("Chưa đăng nhập");
      return [];
    }

    try {
      final user = await supabase
          .from('users')
          .select('id')
          .eq('auth_id', authUser.id)
          .eq('role', 'owner')
          .maybeSingle();

      if (user == null) {
        print("Không phải chủ sân");
        return [];
      }

      final ownerId = user['id'];

      final data = await supabase
          .from('sports_fields')
          .select('*')
          .eq('owner_id', ownerId)
          .order('id');

      if (data is List) {
        return data
            .map((e) => SportField.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print("Dữ liệu trả về không phải là danh sách");
        return [];
      }
    } catch (e) {
      print("Lỗi khi fetch dữ liệu: $e");
      return [];
    }
  }

  void showCreateFieldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: CreateFieldDialogContent(
            onFieldCreated: () {
              setState(() {}); // Tải lại danh sách sau khi thêm sân mới
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SportField>>(
      future: fetchAllSportFields(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Lỗi: ${snapshot.error.toString()}"));
        }

        final fields = snapshot.data ?? [];

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Your Fields",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 100),
                InkWell(
                  onTap: () => showCreateFieldDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: fields.isEmpty
                  ? const Center(child: Text("Bạn chưa có sân nào"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: fields.length,
                      itemBuilder: (context, index) {
                        final field = fields[index];
                        final timeText =
                            (field.time != null && field.time!.isNotEmpty)
                            ? 'Time: ${field.time}'
                            : 'Time: Not set';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                  image: field.imgURL.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(field.imgURL),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      field.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.more_vert),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
