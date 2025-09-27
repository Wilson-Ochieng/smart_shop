
import 'package:flutter/material.dart';
import 'package:shop_smart/screens/edit_upload_product_form.dart';
import 'package:shop_smart/screens/inner_screen/orders/orders_screen.dart';
import 'package:shop_smart/screens/search_screen.dart';
import 'package:shop_smart/services/app_manager.dart';

class DashboardButtonsModel {
  final String text, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.text,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(context) => [
    DashboardButtonsModel(
      text: "Add a new product",
      imagePath: AssetsManager.fashion,
      onPressed: () {
        Navigator.pushNamed(context, EditOrUploadProductScreen.routeName);
      },
    ),
    DashboardButtonsModel(
      text: "inspect all products",
      imagePath: AssetsManager.cosmetics,
      onPressed: () {
        Navigator.pushNamed(context, SearchScreen.routName);
      },
    ),
    DashboardButtonsModel(
      text: "View Orders",
      imagePath: AssetsManager.electronics,
      onPressed: () {
        Navigator.pushNamed(context, OrdersScreenFree.routeName);
      },
    ),
  ];
}
