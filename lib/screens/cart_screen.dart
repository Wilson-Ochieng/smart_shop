import 'package:flutter/material.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/empty_bag.dart';
import 'package:shop_smart/widgets/title_text.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyBagWidget(
        imagePath: AssetsManager.shoppingBasket,
        title: "Your cart is empty",
        subtitle:
            "Looks like your cart is empty add something and make me happy",
        buttonText: "Shop now",
      ),
    );
  }
}