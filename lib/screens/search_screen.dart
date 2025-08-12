import 'package:flutter/material.dart';
import 'package:shop_smart/screens/products/products.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/title_text.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController SearchTextController;
  @override
  void initState() {
    SearchTextController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    SearchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Image.asset(AssetsManager.shoppingCart),

          title: const TitlesTextWidget(label: "Search Products"),
        ),

        body: Column(
          children: [
            TextField(
              controller: SearchController(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),

                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      SearchTextController.clear();
                    });
                  },
                  child: const Icon(Icons.clear, color: Colors.red),
                ),
              ),
              onSubmitted: (value) {
                print("value of the text is   ${value}");
                print("value of the text is   ${SearchTextController.text}");
              },
            ),

            Expanded(
              child: DynamicHeightGridView(
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                builder: (context, index) {
              
                  return  ProductsWidget();
              
                },
                itemCount: 200,
                crossAxisCount: 2,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
