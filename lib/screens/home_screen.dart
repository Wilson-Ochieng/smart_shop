import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_colors.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/screens/products/latest_arrival.dart';
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

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            SizedBox(
              height: size.height * 0.25,
              child: SizedBox(
                height: size.height * 0.25,
                child: ClipRRect(
                   borderRadius: BorderRadius.circular(50),
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Image.asset(
                        AppConstants.bannersImage[index],
                        fit: BoxFit.fill,
                      );
                    },
                    itemCount: AppConstants.bannersImage.length,
                    pagination: SwiperPagination(
                      // alignment: Alignment.center,
                      builder: DotSwiperPaginationBuilder(
                        activeColor: Colors.red,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15.0),

            TitlesTextWidget(label: "Latest Arrivals"),
            SizedBox(height: 15.0),

            SizedBox(
              height: size.height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return LatestArrivalProductsWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
