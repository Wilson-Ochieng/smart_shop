import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/cart_model.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/inner_screen/orders/orders_summary.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class CartBottomSheetWidget extends StatelessWidget {
  const CartBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final totalPrice = cartProvider
        .getTotal(productsProvider: productsProvider)
        .toStringAsFixed(2);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: kBottomNavigationBarHeight + 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: TitlesTextWidget(
                        label:
                            "Total (${cartProvider.getCartItems.length}/${cartProvider.getQty()} items)",
                      ),
                    ),
                    SubtitleTextWidget(
                      label: "Ksh $totalPrice", // Changed from $ to Ksh
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // IMPORTANT: Save current cart state BEFORE navigating
                  final currentCartItems = Map<String, CartModel>.from(cartProvider.getCartItems);
                  final currentTotalQty = cartProvider.getQty();
                  
                  // Reset restore flags BEFORE creating new order
                  cartProvider.resetRestoreFlags();
                  
                  // Navigate to order summary
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderSummaryScreen(
                        cartItems: currentCartItems,
                        totalPrice: totalPrice,
                        totalQty: currentTotalQty,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Checkout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}