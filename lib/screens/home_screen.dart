import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/consts/app_constants.dart';
import 'package:shop_smart/providers/products_provider.dart';
import 'package:shop_smart/screens/products/ctg_roundedimage.dart';
import 'package:shop_smart/screens/products/latest_arrival.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class HomeScreen extends StatelessWidget {
    static const routName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        title: const AppNameTextWidget(fontSize: 20),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              SizedBox(
                height: size.height * 0.25,
                child: SizedBox(
                  height: size.height * 0.25,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Swiper(
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.asset(
                          AppConstants.bannersImage[index],
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: AppConstants.bannersImage.length,
                      pagination: SwiperPagination(
                        // alignment: Alignment.center,
                        builder: DotSwiperPaginationBuilder(
                          activeColor: Colors.red,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15.0),

              TitlesTextWidget(label: "Latest Arrivals"),
              SizedBox(height: 15.0),

              SizedBox(
                height: size.height * 0.2,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return ChangeNotifierProvider.value(
                      value: productsProvider.getProducts[index],

                      
                      child: LatestArrivalProductsWidget());
                  },
                ),
              ),

              SizedBox(height: 15.0),

              TitlesTextWidget(label: "Categories"),
              SizedBox(height: 15.0),

              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),

                children: List.generate(AppConstants.CategoriesList.length, (
                  index,
                ) {
                  return CategoryRoundedWidget(
                    image: AppConstants.CategoriesList[index].image,
                    name: AppConstants.CategoriesList[index].name,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
