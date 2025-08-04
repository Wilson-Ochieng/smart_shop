import 'package:flutter/material.dart';
import 'package:shop_smart/widgets/title_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(

        title: TitlesTextWidget(label: "LoginScreen"),
      ),


      body: Column(


        children: [


          TextField(
            decoration: InputDecoration(

              labelText: "Email"
            ),

            



          ),


          TextField(
            decoration: InputDecoration(

              labelText: "Password"
            )),




        ],
      ),





    );
  }
}