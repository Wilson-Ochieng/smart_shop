import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/product_model.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/products/products.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/title_text.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

class SearchScreen extends StatefulWidget {
  static const routName = "/SearchScreen";
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;
  List<ProductModel> productListSearch = [];

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();

    /// Fetch products from Firestore when screen loads
    Future.microtask(() =>
        Provider.of<ProductsProvider>(context, listen: false).fetchProducts());
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final isLoading = productsProvider.isLoading;

    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;

    List<ProductModel> productList = passedCategory == null
        ? productsProvider.getProducts
        : productsProvider.findByCategory(categoryName: passedCategory);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.shoppingCart),
          ),
          title: TitlesTextWidget(label: passedCategory ?? "Search products"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : productList.isEmpty
                ? const Center(child: TitlesTextWidget(label: "No product found"))
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 15.0),
                        TextField(
                          controller: searchTextController,
                          decoration: InputDecoration(
                            hintText: "Search my products now",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                searchTextController.clear();
                                setState(() {
                                  productListSearch.clear();
                                });
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              productListSearch =
                                  productsProvider.searchQuery(
                                searchText: searchTextController.text,
                                passedList: productList,
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 15.0),
                        if (searchTextController.text.isNotEmpty &&
                            productListSearch.isEmpty)
                          const Center(
                            child: TitlesTextWidget(label: "No products found"),
                          ),
                        Expanded(
                          child: DynamicHeightGridView(
                            itemCount: searchTextController.text.isNotEmpty
                                ? productListSearch.length
                                : productList.length,
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            builder: (context, index) {
                              final product =
                                  searchTextController.text.isNotEmpty
                                      ? productListSearch[index]
                                      : productList[index];

                              return ProductsWidget(productId: product.productId);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
