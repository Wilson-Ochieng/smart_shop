import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/providers/viewed_recently_provider.dart';
import 'package:shop_smart/screens/products/products.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/services/my_app_functions.dart';
import 'package:shop_smart/widgets/empty_bag.dart';
import 'package:shop_smart/widgets/title_text.dart';

class ViewedRecently extends StatelessWidget {
  static const routName = "/ViewedRecentlyScreen";
  const ViewedRecently({super.key});
  final bool isEmpty = true;

  //condition?true:false
  @override
  Widget build(BuildContext context) {
    final viewedProdProvider = Provider.of<ViewedProdProvider>(context);

    return viewedProdProvider.getViewedProds.isEmpty
        ? Scaffold(
            body: EmptyBagWidget(
              imagePath: AssetsManager.shoppingBasket,
              title: "No Products Viewed yet",
              subtitle:
                  "Looks like your cart is empty add something and make me happy",
              buttonText: "Shop now",
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(AssetsManager.shoppingCart),
              ),
              title: TitlesTextWidget(label: "Viewed Recently (${viewedProdProvider.getViewedProds})"),
              actions: [
                IconButton(
                  onPressed: () {

                     MyAppFunctions.showErrorOrWarningDialog(
                      isError: false,
                      context: context,
                      fct: () {
                        viewedProdProvider.clearLocalViewedProd();
                      },
                      subtitle: "Clear Cart",
                    );
                  },
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            body: DynamicHeightGridView(
              itemCount: viewedProdProvider.getViewedProds.length,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              builder: (ctx, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProductsWidget(
                    productId:viewedProdProvider.getViewedProds.values.toList()[index].productId,
                  ),
                );
              },
            ),
          );
  }
}
