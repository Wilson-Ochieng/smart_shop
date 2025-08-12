import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_colors.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),

      body: SizedBox(
        height: size.height * 0.25,
        child: Column(
          children: [
            Swiper(
              itemBuilder: (context, int index) {
                return Image.network(
                  "https://via.placeholder.com/350x150",

                  fit: BoxFit.fill,
                );
              },
              itemCount: 3,
            ),
          ],
        ),
      ),
    );
  }
}
