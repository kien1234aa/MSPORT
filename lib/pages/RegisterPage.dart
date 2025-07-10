import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/database/db_user.dart';
import 'package:msport/model/user.dart';
import 'package:msport/widget/ForG.dart';
import 'package:msport/widget/mybutton.dart';
import 'package:msport/widget/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? selectedRole;
  final List<String> roles = ['customer', 'owner'];
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  final auth = AuthService();
  DBUser repository = DBUser();

  void register() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Họ tên không hợp lệ!")));
    } else if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email không hợp lệ!")));
    } else if (passwordController.text.isEmpty ||
        passwordController.text.length < 8) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mật khẩu không hợp lệ!")));
    } else if (phonenumberController.text.isEmpty ||
        phonenumberController.text.length != 10) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Số điện thoại không hợp lệ!")));
    } else if (selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Vui lòng chọn vai trò!")));
    } else {
      try {
        // 🟢 Bước 1: Đăng ký
        final res = await auth.registerWitEmail(
          emailController.text,
          passwordController.text,
        );
        final authUser =
            res.user; // Lấy user từ kết quả trả về của registerWitEmail

        if (authUser == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Đăng ký thất bại.")));
          return;
        }

        // 🟢 Bước 2: Tạo user
        User1 newUser = User1(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          phone: phonenumberController.text.trim(),
          role: selectedRole,
          auth_id: authUser.id, // ✅ Gán auth_id
        );

        await repository.createUser(newUser);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Đăng ký thành công!")));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: 325,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    MyTextField(
                      title: "name",
                      w: 20,
                      controller: nameController,
                    ),
                    SizedBox(height: 10),
                    MyTextField(
                      title: "email",
                      w: 20,
                      controller: emailController,
                    ),
                    SizedBox(height: 10),
                    MyTextField(
                      title: "password",
                      w: 20,
                      controller: passwordController,
                    ),
                    SizedBox(height: 10),
                    MyTextField(
                      title: "phone number",
                      w: 20,
                      controller: phonenumberController,
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          hint: Text("role"),
                          icon: Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          items: roles.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue; // 🟢 this is key
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "you already have an account",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "login now",
                            style: TextStyle(color: Colors.green),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go("/login");
                              },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    MyButton(
                      h: 60,
                      w: 184,
                      content: "Đăng ký",
                      onTap: register,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "register with with:",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20),
                        ForG(img: "assets/icons/facebook.png"),
                        ForG(img: "assets/icons/google.png"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
