import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

Future init() async {
  sharedPreferences = await SharedPreferences.getInstance();
}
