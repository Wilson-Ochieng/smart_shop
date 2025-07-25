import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingBasket),
        ),

        title: Text("Profile Screen"),
      ),

      body: Column(
        children: [
          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: TitleTextWidget(
                label: "Please login to have unlimited Access",
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
            
                    color: Theme.of(context).cardColor,
                    border: BoxBorder.all(color: Colors.blue, width: 3),
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [


              TitleTextWidget(label: "Wilson Ochieng"),
              SubtitleTextWidget(label: "wilsonochieng718@gmail.com")
            ],
          )
        ]

      ),
    );
  }
}
