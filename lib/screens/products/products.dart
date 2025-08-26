import 'dart:developer';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/models/product_model.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/inner_screen/products_details.dart';
import 'package:shop_smart/screens/products/heart_btn.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProductsWidget extends StatefulWidget {
  const ProductsWidget({super.key, this.productId});

  final String? productId;

  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrentProduct = productsProvider.findProdId(widget.productId!);

    Size size = MediaQuery.of(context).size;
    return getCurrentProduct == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(3.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  ProductsDetailsScreen.routName,
                  arguments: getCurrentProduct.productId,
                );

                log("Navigate to product details screen");
              },

              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FancyShimmerImage(
                      imageUrl: getCurrentProduct!.productImage,

                      height: size.height * 0.2,
                      width: double.infinity,
                    ),
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: TitlesTextWidget(
                          label: getCurrentProduct.productTitle,
                          fontSize: 18,
                          maxLines: 2,
                        ),
                      ),
                      Flexible(child: HeartButtonWidget()),
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
                            label: getCurrentProduct.productPrice,
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
