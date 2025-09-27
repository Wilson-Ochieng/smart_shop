import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/products/heart_btn.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ProductsDetailsScreen extends StatefulWidget {
  static const routName = "/ProductDetailsScreen";
  const ProductsDetailsScreen({super.key});

  @override
  State<ProductsDetailsScreen> createState() => _ProductsDetailsWidgetState();
}

class _ProductsDetailsWidgetState extends State<ProductsDetailsScreen> {
  /// Kenyan Shilling formatter
  String _formatPrice(String price) {
    final formatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
      decimalDigits: 0,
    );
    return formatter.format(double.tryParse(price) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    String? productId = ModalRoute.of(context)!.settings.arguments as String?;
    final getCurrentProduct = productsProvider.findByProdId(productId!);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),
      body: getCurrentProduct == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: Column(
                children: [
                  FancyShimmerImage(
                    imageUrl: getCurrentProduct.productImage,
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
                                getCurrentProduct.productTitle,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SubtitleTextWidget(
                              label: _formatPrice(getCurrentProduct.productPrice),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HeartButtonWidget(
                                bkgColor: Colors.blue.shade100,
                                productId: getCurrentProduct.productId,
                              ),
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
                                    onPressed: () {
                                      if (!cartProvider.isProdinCart(
                                        productId: getCurrentProduct.productId,
                                      )) {
                                        cartProvider.addProductToCart(
                                          productId: getCurrentProduct.productId,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      cartProvider.isProdinCart(
                                        productId: getCurrentProduct.productId,
                                      )
                                          ? Icons.check
                                          : Icons.add_shopping_cart_outlined,
                                    ),
                                    label: Text(
                                      cartProvider.isProdinCart(
                                        productId: getCurrentProduct.productId,
                                      )
                                          ? "In cart"
                                          : "Add to cart",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TitlesTextWidget(label: "About this Item"),
                            SubtitleTextWidget(
                              label: "In ${getCurrentProduct.productCategory}",
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SubtitleTextWidget(
                          label: getCurrentProduct.productDescription,
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
