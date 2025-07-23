import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider  with ChangeNotifier{
static const THEMESTATUS ="THEME_STATUS";
bool _darkTheme = false;
bool get getIsDarkTheme => _darkTheme;

ThemeProvider(){

getTheme();

}
setDarkTheme(bool value) async{

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(THEMESTATUS, value);
  _darkTheme =value;
  notifyListeners();
}

Future<bool> getTheme() async{

  SharedPreferences prefs = await SharedPreferences.getInstance();
  _darkTheme = prefs.getBool(THEMESTATUS)?? false;
  notifyListeners();
  return _darkTheme;
}



}