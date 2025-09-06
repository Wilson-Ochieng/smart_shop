import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/models/dashboardboard_model.dart';
import 'package:shop_smart/providers/theme_provider.dart';
import 'package:shop_smart/screens/auth/login_screen.dart';
import 'package:shop_smart/services/app_manager.dart';
import 'package:shop_smart/services/my_app_functions.dart';
import 'package:shop_smart/widgets/dashboard_btn.dart';
import 'package:shop_smart/widgets/title_text.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/DashboardScreen';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(label: "Dashboard Screen"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.shoppingCart),
        ),
        actions: [
          // Theme toggle
          IconButton(
            onPressed: () {
              themeProvider.setDarkTheme(!themeProvider.getIsDarkTheme);
            },
            icon: Icon(themeProvider.getIsDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
          ),

          // Strategic Logout Icon
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await MyAppFunctions.showErrorOrWarningDialog(
                context: context,
                subtitle: "Are you sure you want to Sign Out?",
                fct: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'You have been Signed Out Successfully',
                      ),
                    ),
                  );

                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routName,
                  );
                },
                isError: false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          DashboardButtonsModel.dashboardBtnList(context).length,
          (index) => DashboardButtonsWidget(
            text: DashboardButtonsModel.dashboardBtnList(context)[index].text,
            imagePath:
                DashboardButtonsModel.dashboardBtnList(context)[index].imagePath,
            onPressed:
                DashboardButtonsModel.dashboardBtnList(context)[index].onPressed,
          ),
        ),
      ),
    );
  }
}
