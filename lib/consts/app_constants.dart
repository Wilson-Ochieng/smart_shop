import 'package:flutter/material.dart';
import 'package:shop_smart/models/categories_model.dart';
import 'package:shop_smart/services/app_manager.dart';

class AppConstants {
  static const String imageUrl =
      "https://i.ibb.co/8r1Ny2n/20-Nike-Air-Force-1-07.png";

  static List<String> bannersImage = [
    AssetsManager.banner1,
    AssetsManager.banner2,
    AssetsManager.banner3,
    
  ];

  static List<CategoriesModel> CategoriesList = [
    CategoriesModel(id: "Phones", image: AssetsManager.mobiles, name: "Phones"),
    CategoriesModel(id: "Laptops", image: AssetsManager.pc, name: "Laptops"),
    CategoriesModel(
      id: "Electronics",
      image: AssetsManager.electronics,
      name: "Electronics",
    ),
    CategoriesModel(id: "Watches", image: AssetsManager.watch, name: "Watches"),
    CategoriesModel(
      id: "Clothes",
      image: AssetsManager.fashion,
      name: "Clothes",
    ),
    CategoriesModel(id: "Shoes", image: AssetsManager.shoes, name: "Shoes"),
    CategoriesModel(id: "Books", image: AssetsManager.book, name: "Books"),
    CategoriesModel(
      id: "Cosmetics",
      image: AssetsManager.cosmetics,
      name: "Cosmetics",
    ),
  ];

  
  static List<String> categoriesList = [
    'Phones',
    'Laptops',
    'Electronics',
    'Watches',
    'Clothes',
    'Shoes',
    'Books',
    'Cosmetics',
    "Accessories",
  ];
   static List<DropdownMenuItem<String>>? get categoriesDropDownList {
    List<DropdownMenuItem<String>>? menuItem =
        List<DropdownMenuItem<String>>.generate(
      categoriesList.length,
      (index) => DropdownMenuItem(
        value: categoriesList[index],
        child: Text(categoriesList[index]),
      ),
    );
    return menuItem;
  }
}
