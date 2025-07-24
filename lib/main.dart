import 'package:flutter/material.dart';
import 'package:shop_smart/consts/theme_data.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/root_screen.dart';
import 'package:shop_smart/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_)
        
        {

          return ThemeProvider();
        })
      ],
      child: Consumer<ThemeProvider>(
        builder: (context,themeProvider,child) {
          return MaterialApp(
            theme: Styles.themeData(isDarktheme: themeProvider.getIsDarkTheme, context: context),
            home: RootScreen(),
          );
        }
      ),
    );
  }
}
