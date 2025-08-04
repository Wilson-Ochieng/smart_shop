import 'package:flutter/material.dart';
import 'package:shop_smart/widgets/title_text.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: Center(
        child: TitlesTextWidget(label: "SeachScreen"),
      ),
    );
  }
}