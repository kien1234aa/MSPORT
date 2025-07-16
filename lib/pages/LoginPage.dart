import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/auth/auth_service.dart';
import 'package:msport/model/user.dart';
import 'package:msport/widget/ForG.dart';
import 'package:msport/widget/mybutton.dart';
import 'package:msport/widget/text_field.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    AuthService auth = AuthService();
    bool isLoading = false;
    void signInWithGoogle() async {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
    }

    void nextHomePage() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email không được để trống!")),
        );
        return;
      } else if (password.isEmpty || password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu phải từ 6 ký tự trở lên!")),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        // Đăng nhập bằng Supabase Auth
        final response = await auth.loginWithEmail(email, password);

        if (response.user != null) {
          final userId = response.user!.id;

          // Lấy thông tin người dùng từ bảng `users`
          final userMap = await Supabase.instance.client
              .from('users')
              .select()
              .eq('email', email)
              .single();
          final userData = User1.fromMap(userMap);
          if (context.mounted) {
            context.go('/home', extra: userData);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đăng nhập thất bại. Vui lòng kiểm tra lại!"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

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
                      "Log in",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    MyTextField(
                      title: "email",
                      w: 30,
                      controller: emailController,
                    ),
                    SizedBox(height: 20),
                    MyTextField(
                      title: "password",
                      w: 30,
                      controller: passwordController,
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: "you haven't account?",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "register now",
                            style: TextStyle(color: Colors.green),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.go("/register");
                              },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    isLoading
                        ? CircularProgressIndicator()
                        : MyButton(
                            h: 60,
                            w: 184,
                            content: "Đăng Nhập",
                            onTap: nextHomePage,
                          ),
                    SizedBox(height: 10),
                    Text("login with:", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20),
                        ForG(
                          img: "assets/icons/facebook.png",
                          onTap: signInWithGoogle,
                        ),
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
