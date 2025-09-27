import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/cart_model.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/cart/quantity_btm_sheet.dart';
import 'package:shop_smart/screens/products/heart_btn.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

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
    final cartModel = Provider.of<CartModel>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final getCurrentProduct = productsProvider.findByProdId(cartModel.productId);
    final cartProvider = Provider.of<CartProvider>(context);

    Size size = MediaQuery.of(context).size;
    return getCurrentProduct == null
        ? const SizedBox.shrink()
        : FittedBox(
            child: IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: FancyShimmerImage(
                        imageUrl: getCurrentProduct.productImage,
                        height: size.height * 0.2,
                        width: size.height * 0.2,
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// Title, actions and price
                    IntrinsicWidth(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: size.width * 0.6,
                                child: TitlesTextWidget(
                                  label: getCurrentProduct.productTitle,
                                  maxLines: 2,
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      cartProvider.removeOneItem(
                                        productId: getCurrentProduct.productId,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.red,
                                    ),
                                  ),
                                  HeartButtonWidget(
                                    productId: getCurrentProduct.productId,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          /// Price + Quantity button
                          Row(
                            children: [
                              SubtitleTextWidget(
                                label: _formatPrice(
                                  getCurrentProduct.productPrice,
                                ),
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                              const Spacer(),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await showModalBottomSheet(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                    ),
                                    context: context,
                                    builder: (context) {
                                      return QuantityBottomSheetWidget(
                                        cartModel: cartModel,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(IconlyLight.arrowDown2),
                                label: Text("Qty: ${cartModel.quantity}"),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                            ],
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
