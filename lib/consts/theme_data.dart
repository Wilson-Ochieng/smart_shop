import 'package:flutter/material.dart';
import 'package:shop_smart/consts/app_colors.dart';

class Styles {

  static ThemeData themeData( { required bool isDarktheme, required  BuildContext context }){


  return ThemeData(

    scaffoldBackgroundColor:isDarktheme ? AppColors.darkScaffoldColor: AppColors.lightScaffoldColor,

    cardColor: isDarktheme ?
    const Color.fromARGB(100, 78, 89, 67):
    AppColors.lightCardColor,
    brightness: isDarktheme ? Brightness.dark :Brightness.light
    

  );
  


  }


  
  
  
  
  







}