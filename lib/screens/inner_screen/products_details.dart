import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/screens/products/heart_btn.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProductsDetailsScreen extends StatefulWidget {
  static const routName = "/ProductDetailsScreen";
  const ProductsDetailsScreen({super.key});

  @override
  State<ProductsDetailsScreen> createState() => _ProductsDetailsWidegtState();
}

class _ProductsDetailsWidegtState extends State<ProductsDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigator.canPop(context) ? Navigator.pop(context) : null;
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FancyShimmerImage(
              imageUrl: AppConstants.imageUrl,

              height: size.height * 0.38,
              width: double.infinity,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Flexible(
                        child: Text(
                          "Title" * 18,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      SubtitleTextWidget(
                        label: "1550\$",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HeartButtonWidget(bkgColor: Colors.blue.shade100),

                        const SizedBox(width: 20),

                        Expanded(
                          child: SizedBox(
                            height: kBottomNavigationBarHeight - 10,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text("Add to cart"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitlesTextWidget(label: "About this Item"),
                      SubtitleTextWidget(label: "In Phone"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SubtitleTextWidget(label: "Description" * 155),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
