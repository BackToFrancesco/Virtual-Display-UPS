import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  await dotenv.load(fileName: "global_vars.env");
  runApp(const App());
}
