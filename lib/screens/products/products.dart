
import 'dart:developer';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProductsWidget extends StatelessWidget {
  const ProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: GestureDetector(

        onTap: () {

          log("Navigate to product details screen");
          
        },


        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FancyShimmerImage(
                imageUrl: AppConstants.imageUrl,
        
                height: size.height * 0.2,
                width: double.infinity,
              ),
            ),
        
            SizedBox(height: 10),
        
            Row(
              
              children: [
                Flexible(flex: 2, child: TitlesTextWidget(label: "Title" * 10,fontSize: 18,maxLines: 2,)),
                Flexible(
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(IconlyLight.heart),
                  ),
                ),
              ],
            ),
        
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 5,
                    child: SubtitleTextWidget(
                      label: "1550\$",
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  Flexible(
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.lightBlue,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                      
                        onTap: () {},
                      
                        splashColor: Colors.red,
                      
                        child: Icon(Icons.add_shopping_cart_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
