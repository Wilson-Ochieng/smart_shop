import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_colors.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TitleTextWidget(label: "Welcome to Smart Shop"*20),
           SubtitleTextWidget(  label: "Smart Shop"),

            ElevatedButton(onPressed: () {}, child: const Text("Hello  World")),
            SwitchListTile(
              title: Text(themeProvider.getIsDarkTheme ? "Dark Theme" :"Light Theme"),
              value: themeProvider.getIsDarkTheme,
              onChanged: (value) {
                themeProvider.setDarkTheme(value);
              print('Theme State , ${themeProvider.getIsDarkTheme}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
