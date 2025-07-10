import 'package:msport/model/bookings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:msport/model/user.dart';

class DBUser {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'users';

  // CREATE - Add new user
  Future<User1?> createUser(User1 user) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(user.toMap())
          .select()
          .single();

      return User1.fromMap(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // CREATE - bookings
  Future<Booking> createBooking(Booking booking) async {
    try {
      print("📤 Sending booking to Supabase: ${booking.toJson()}");

      final response = await _supabase
          .from('bookings')
          .insert(booking.toJson())
          .select()
          .single();

      print("✅ Booking created response: $response");

      return Booking.fromJson(response);
    } catch (e) {
      print('❌ Error creating booking: $e');

      if (e is PostgrestException) {
        print('Supabase Error Details: ${e.message}');
      }

      throw Exception('Failed to create booking');
    }
  }

  // READ - Get user by ID
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final supabase = Supabase.instance.client;

    // Lấy user từ Supabase Auth (người dùng đang đăng nhập)
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('Chưa có người dùng đăng nhập.');
      return null;
    }

    final authId = user.id;

    // Truy vấn thông tin từ bảng "users" theo auth_id
    final response = await supabase
        .from('users')
        .select()
        .eq('auth_id', authId)
        .maybeSingle(); // Lấy 1 user (hoặc null nếu không có)

    if (response == null) {
      print('Không tìm thấy thông tin user với auth_id: $authId');
      return null;
    }
    return response;
  }

  // upadate status sport field
  Future<void> updateItemStatusToUnactive(int itemId) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('sports_fields')
          .update({'status': 'inactive'})
          .eq('id', itemId)
          .select(); // Supabase SDK mới yêu cầu thêm .select() để nhận lại dữ liệu

      print('✅ Cập nhật thành công: $response');
    } catch (error) {
      print('❌ Lỗi khi cập nhật: $error');
    }
  }

  //Get booking of user
  Future<Map<String, dynamic>?> getBookingOfUser(int userID) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('bookings')
        .select()
        .eq('id', userID)
        .maybeSingle(); // Lấy 1 user (hoặc null nếu không có)

    if (response == null) {
      print('Không tìm thấy thông tin user với auth_id: $userID');
      return null;
    }
    return response;
  }

  Future<Map<String, dynamic>?> getSportFieldBooked(int idField) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('sports_fields')
        .select()
        .eq('id', idField)
        .maybeSingle(); // Lấy 1 user (hoặc null nếu không có)

    if (response == null) {
      print('Không tìm thấy thông tin user với auth_id: $idField');
      return null;
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> getBookedFieldsByUser(String role) async {
    final user = await DBUser().getCurrentUserData();
    final userId = user?['id'];

    final response = await Supabase.instance.client
        .from('bookings')
        .select('*, sports_fields(*)')
        .eq(role, userId);

    if (response != null && response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Không thể lấy dữ liệu đặt sân');
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsByOwner() async {
    final user = await DBUser().getCurrentUserData();
    final userId = user?['id'];
    final response = await Supabase.instance.client
        .from('bookings')
        .select('id, user_id, sports_fields(*)')
        .filter(
          'sports_fields.owner_id',
          'eq',
          userId,
        ); // chỉ lấy sân của owner

    if (response != null && response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Không thể lấy danh sách đặt sân theo owner');
    }
  }
}
