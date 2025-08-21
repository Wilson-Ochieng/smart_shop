import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shop_smart/consts/theme_data.dart';
import 'package:shop_smart/firebase_options.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/root_screen.dart';
import 'package:shop_smart/screens/auth/forgot_password.dart';
import 'package:shop_smart/screens/auth/login_screen.dart';
import 'package:shop_smart/screens/auth/register_screen.dart';
import 'package:shop_smart/screens/cart/cart_screen.dart';
import 'package:shop_smart/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/screens/inner_screen/orders/orders_screen.dart';
import 'package:shop_smart/screens/inner_screen/products_details.dart';
import 'package:shop_smart/screens/inner_screen/viewed_recently.dart';
import 'package:shop_smart/screens/inner_screen/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return ThemeProvider();
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: Styles.themeData(
              isDarktheme: themeProvider.getIsDarkTheme,
              context: context,
            ),

            initialRoute: FirebaseAuth.instance.currentUser == null
                ? LoginScreen.routName
                : RootScreen.routName,

            routes: {
              LoginScreen.routName: (context) => const LoginScreen(),

              RegisterScreen.routName: (context) => const RegisterScreen(),

              RootScreen.routName: (context) => const RootScreen(),
              CartScreen.routName: (context) => const CartScreen(),

              HomeScreen.routName: (context) => const HomeScreen(),

              ProductsDetailsScreen.routName: (context) =>
                  const ProductsDetailsScreen(),
              ViewedRecently.routName: (context) => const ViewedRecently(),
              WishlistScreen.routName: (context) => const WishlistScreen(),
              OrdersScreenFree.routeName: (context) => const OrdersScreenFree(),
              ForgotPasswordScreen.routeName: (context) =>
                  const ForgotPasswordScreen(),
            },

            // home: SignUpScreen(),
          );
        },
      ),
    );
  }
}
