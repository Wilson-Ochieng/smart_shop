import 'dart:developer';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/models/product_model.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/inner_screen/products_details.dart';
import 'package:shop_smart/screens/products/heart_btn.dart';
import 'package:shop_smart/services/my_app_functions.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';

class LatestArrivalProductsWidget extends StatelessWidget {
  const LatestArrivalProductsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final productsModel = Provider.of<ProductModel>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(
            context,
            ProductsDetailsScreen.routName,
            arguments: productsModel.productId,
          );

          log("ToDo add the navigate to the product details screen");
        },
        child: SizedBox(
          width: size.width * 0.45,

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: FancyShimmerImage(
                    imageUrl: productsModel.productImage,
                    height: size.width * 0.24,
                    width: size.width * 0.32,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      productsModel.productTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    FittedBox(
                      child: Row(
                        children: [
                          HeartButtonWidget(),
                          IconButton(
                            onPressed: () {
                              if (cartProvider.isProdinCart(
                                productId: productsModel.productId,
                              ))
                                ;

                              cartProvider.addProductToCart(
                                productId: productsModel.productId,
                              );
                            },
                            icon: Icon(
                              cartProvider.isProdinCart(
                                    productId: productsModel.productId,
                                  )
                                  ? Icons.check
                                  : Icons.add_shopping_cart_outlined,

                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      child: SubtitleTextWidget(
                        label: "${productsModel.productPrice}\$",
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
