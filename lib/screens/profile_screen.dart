import 'package:flutter/material.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetManager.profileImagesPath),
        ),

        title: Text("Profile Screen"),
      )
      
      ,

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TitleTextWidget(label: "Please login to have unlimited Access"),
      )
    );
  }
}