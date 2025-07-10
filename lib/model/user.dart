class User1 {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? role;
  DateTime? createdAt;
  String? auth_id;

  User1({
    this.name,
    this.email,
    this.password,
    this.phone,
    this.role,
    this.createdAt,
    this.auth_id,
  });

  factory User1.fromMap(Map<String, dynamic> map) {
    return User1(
      name: map['name'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
      phone: map['phone'] as String?,
      role: map['role'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'auth_id': auth_id, // ✅ thêm dòng này
    };
  }
}
