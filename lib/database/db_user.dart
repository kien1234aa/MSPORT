import 'package:flutter/material.dart';
import 'package:msport/model/BookingDetail.dart';
import 'package:msport/model/bookings.dart';
import 'package:msport/model/sport_field.dart';
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

  // Tạo sân
  Future<void> createSport(SportsField field) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('sports_fields').insert(field.toJson());
    } catch (e) {
      if (e is PostgrestException) {
        debugPrint("Supabase Error: ${e.message}");
        throw Exception(e.message); // Hoặc trả về lỗi tùy ý
      } else {
        debugPrint("Unexpected Error: $e");
        throw Exception("Lỗi không xác định");
      }
    }
  }

  //Lấy tất cả các sân dựa trên id owner
  Future<List<SportsField>> getAllField(int idOwner) async {
    final response = await _supabase
        .from("sports_fields")
        .select()
        .eq("owner_id", idOwner);
    if (response is List) {
      return response.map((json) => SportsField.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách sân');
    }
  }

  //Lấy auth_id của user
  String getCurrentUserAuthId() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    return user.id; // Đây là auth_id
  }

  //lấy id của user dựa vào auth id
  Future<int> getCurrentUserId() async {
    final supabase = Supabase.instance.client;
    final authId = getCurrentUserAuthId();

    final response = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', authId)
        .single();

    return response['id'];
  }

  Future<void> createBooking(Booking booking) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('bookings').insert(booking.toJson());
    } catch (e) {
      if (e is PostgrestException) {
        debugPrint("Supabase Error: ${e.message}");
        throw Exception(e.message);
      } else {
        debugPrint("Unexpected Error: $e");
        throw Exception("Lỗi không xác định khi đặt sân");
      }
    }
  }

  Future<List<SportsField>> getFieldBooked(int ownerId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase.rpc(
      'get_field_booked',
      params: {'owner_id_input': ownerId},
    );

    if (response == null) {
      throw Exception("Không có dữ liệu trả về");
    }
    return (response as List)
        .map((e) => SportsField.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
