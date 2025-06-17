import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:msport/widget/mybutton.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    void nextLoginPage(){
      context.go("/login");
    }
    void nextRegisterPage(){
      context.go("/register");
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/background.png",fit:BoxFit.cover),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset("assets/images/logo.png",height:300,width: 300,)),
              SizedBox(height: 200,),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyButton(h: 60, w: 250, content: "Bạn đã có tài khoản",onTap: nextLoginPage,),
                  SizedBox(height: 20,),
                  GestureDetector(
                    onTap: nextRegisterPage,
                    child: Container(
                                    width: 250,
                                    height: 60,
                                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:Colors.white,
                                     ),
                                    child: Center(
                    child: Text("Bạn chưa có tài khoản",style: TextStyle(fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                  ),
                ],
              )
              
            ], 
          )

        ],
      ),
    );
  }
}