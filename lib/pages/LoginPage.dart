import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/widget/ForG.dart';
import 'package:msport/widget/mybutton.dart';
import 'package:msport/widget/text_field.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController phonenunberController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    void nextHomePage(){
      
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/background.png",fit:BoxFit.cover),
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
                    SizedBox(height: 30,),
                    Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    SizedBox(height: 30,),
                    MyTextField(title: "email",w: 30,controller: phonenunberController,),
                    SizedBox(height: 20,),
                    MyTextField(title: "password",w: 30,controller: passwordController,),
                    SizedBox(height: 10,),
                    RichText(
                      text:TextSpan(
                        text: "you haven't account?",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        children: [
                          TextSpan(
                            text: "register now",
                            style: TextStyle(
                              color: Colors.green
                            ),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.go("/register");
                            }
                          ),
                          
                        ]
                      )
                    ),
                    SizedBox(height: 10,),
                    MyButton(h: 60, w: 184, content: "Đăng Nhập",onTap: nextHomePage,),
                    SizedBox(height: 10,),
                    Text("login with:",style: TextStyle(color: Colors.grey),),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20,),
                        ForG(img: "assets/icons/facebook.png",),
                        ForG(img: "assets/icons/google.png",),
                        SizedBox(height: 20,),
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