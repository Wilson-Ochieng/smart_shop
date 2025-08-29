import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/providers/cart_provider.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/cart/cart_widget.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/empty_bag.dart';
import 'package:shop_smart/widgets/title_text.dart';

import 'bottom_checkout.dart';

class CartScreen extends StatelessWidget {
  static const routName = "/CartScreen";
  const CartScreen({super.key});
  final bool isEmpty = false;

  //condition?true:false
  @override
  Widget build(BuildContext context) {
    // final productsProvider = Provider.of<ProductsProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    return cartProvider.getCartItems.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.shoppingBasket,
              title: "Your cart is empty",
              subtitle:
                  "Looks like your cart is empty add something and make me happy",
              buttonText: "Shop now",
            ),
          )
        : Scaffold(
            bottomSheet: CartBottomSheetWidget(),
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(AssetsManager.shoppingCart),
              ),
              title:  TitlesTextWidget(label: "Cart is (${cartProvider.getCartItems.length})"),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(

                  child: ListView.builder(
                    itemCount: cartProvider.getCartItems.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider.value(
                        value: cartProvider.getCartItems.values.toList()[index],
                        
                        
                        
                        
                        child: const CartWidget());
                    },
                  ),
                ),
                SizedBox(height: kBottomNavigationBarHeight+10,)
              ],
            ),
          );
  }
}
