import 'package:flutter/material.dart';
import 'package:shop_smart/providers/theme_provider.dart';
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
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.red,
          primarySwatch: Colors.green,
      
        ),
        home: HomeScreen(),
      ),
    );
  }
}
