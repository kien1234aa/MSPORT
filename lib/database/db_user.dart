import 'package:flutter/material.dart';
import 'package:msport/model/BookingDetail.dart';
import 'package:msport/model/Notification.dart';
import 'package:msport/model/bookings.dart';
import 'package:msport/model/sport_field.dart';
import 'package:msport/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DBUser {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// =======================
  /// USER FUNCTIONS
  /// =======================

  Future<User1?> createUser(User1 user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toMap())
          .select()
          .single();

      return User1.fromMap(response);
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('auth_id', user.id)
        .maybeSingle();

    return response;
  }

  Future<String> getNameCurrent() async {
    final user = await getCurrentUserData();
    return user?['name'] ?? 'Người dùng';
  }

  String getCurrentUserAuthId() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    return user.id;
  }

  Future<int> getCurrentUserId() async {
    final response = await _supabase
        .from('users')
        .select('id')
        .eq('auth_id', getCurrentUserAuthId())
        .single();

    return response['id'];
  }

  /// =======================
  /// SPORT FIELD FUNCTIONS
  /// =======================

  Future<void> createSport(SportsField field) async {
    await _supabase.from('sports_fields').insert(field.toJson());
  }

  Future<void> updateItemStatusToUnactive(int fieldId) async {
    await _supabase
        .from('sports_fields')
        .update({'status': 'inactive'})
        .eq('id', fieldId);
  }

  Future<List<SportsField>> getAllField(int ownerId) async {
    final response = await _supabase
        .from('sports_fields')
        .select()
        .eq('owner_id', ownerId);

    return (response as List)
        .map((json) => SportsField.fromJson(json))
        .toList();
  }

  Future<SportsField?> getSportFieldById(int idField) async {
    final response = await _supabase
        .from('sports_fields')
        .select()
        .eq('id', idField)
        .maybeSingle();

    if (response == null) return null;
    return SportsField.fromJson(response);
  }

  Future<String> getOwnerAuthIdFromFieldId(int fieldId) async {
    final result = await _supabase.rpc(
      'get_owner_auth_id',
      params: {'p_field_id': fieldId},
    );

    if (result == null) {
      throw Exception('Không tìm thấy chủ sân cho fieldId: $fieldId');
    }

    return result as String;
  }

  /// =======================
  /// BOOKING FUNCTIONS
  /// =======================

  Future<void> createBooking(Booking booking) async {
    await _supabase.from('bookings').insert(booking.toJson());
  }

  Future<List<Map<String, dynamic>>> getBookedFieldsByUser(String role) async {
    final userId = (await getCurrentUserData())?['id'];

    final response = await _supabase
        .from('bookings')
        .select('*, sports_fields(*)')
        .eq(role, userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getBookingsByOwner() async {
    final userId = (await getCurrentUserData())?['id'];

    final response = await _supabase
        .from('bookings')
        .select('id, user_id, sports_fields(*)')
        .filter('sports_fields.owner_id', 'eq', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<SportsField>> getFieldBooked(int ownerId) async {
    final response = await _supabase.rpc(
      'get_field_booked',
      params: {'owner_id_input': ownerId},
    );

    return (response as List)
        .map((e) => SportsField.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> bookFieldAndNotify({
    required int fieldId,
    required double pricePerHour,
    required String time,
  }) async {
    final userData = await getCurrentUserData();
    final userName = await getNameCurrent();

    if (userData == null)
      throw Exception('Không tìm thấy thông tin người dùng');

    final userId = userData['id'];
    final senderAuthId = getCurrentUserAuthId();
    final ownerAuthId = await getOwnerAuthIdFromFieldId(fieldId);

    // Booking
    Booking booking = Booking(
      userId: userId,
      fieldId: fieldId,
      date: DateTime.now(),
      totalPrice: pricePerHour,
      status: "pending",
      createdAt: DateTime.now(),
    );

    await createBooking(booking);

    // Notification
    NotificationModel notification = NotificationModel(
      title: "Yêu cầu đặt sân",
      content: "$userName muốn đặt sân khung giờ $time",
      readnoti: false,
      createdAt: DateTime.now(),
      senderId: senderAuthId,
      receiverId: ownerAuthId,
      type: "bookings",
    );

    await insertNotification(notification);
  }

  /// =======================
  /// NOTIFICATION FUNCTIONS
  /// =======================

  Future<void> insertNotification(NotificationModel notification) async {
    await _supabase.from('notifications').insert(notification.toJson());
  }

  Future<int> countUnreadNotifications() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('notifications')
        .select()
        .eq('receiver_id', Supabase.instance.client.auth.currentUser!.id)
        .eq('readnoti', false);

    return data.length;
  }

  //Lấy thông báo dụa trên auth_id
  Future<List<NotificationModel>> getNotificationsForCurrentUser() async {
    final supabase = Supabase.instance.client;

    // Lấy auth_id người dùng hiện tại
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Chưa đăng nhập');
    }

    final authId = currentUser.id;

    // Truy vấn thông báo có receiver_id = authId
    final response = await supabase
        .from('notifications')
        .select()
        .eq('receiver_id', authId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }
}
