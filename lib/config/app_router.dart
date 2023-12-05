import 'package:flutter/material.dart';
import '../screens/alarms/alarms.dart';
import '../screens/dashboard/dashboard.dart';
import '../screens/get_started/get_started.dart';
import '../screens/login/login.dart';
import '../screens/measurements/battery_measurements/battery_measurements.dart';
import '../screens/measurements/bypass_measurements/bypass_measurements.dart';
import '../screens/measurements/input_measurements/input_measurements.dart';
import '../screens/measurements/inverter_measurements/inverter_measurements.dart';
import '../screens/measurements/output_measurements/output_measurements.dart';
import '../screens/personal_data/personal_data.dart';
import '../screens/remote_support_call/remote_support_call.dart';
import '../screens/remote_support_request/remote_support_request.dart';
import '../screens/settings/settings.dart';
import '../screens/splash_screen/splash_screen.dart';
import '../screens/states/states.dart';
import '../screens/ups_connection/ups_connection.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case 'splashScreen':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'getStarted':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const GetStartedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'upsConnection':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UpsConnectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'dashboard':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'states':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const StatesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'alarms':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AlarmsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'settings':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'bypassMeasurements':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const BypassMeasurementsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'inverterMeasurements':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const InverterMeasurementsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'inputMeasurements':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const InputMeasurementsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'batteryMeasurements':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const BatteryMeasurementsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'outputMeasurements':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OutputMeasurementsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'personalData':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PersonalDataScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'login':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'remoteSupportRequest':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RemoteSupportRequestScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      case 'remoteSupportCall':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              RemoteSupportCallScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
      default:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Scaffold(
            body: SafeArea(child: Center(child: Text("Blank"))),
          ), //unknown screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _getSlideTransition(animation, child);
          },
        );
    }
  }

  SlideTransition _getSlideTransition(Animation animation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.ease;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
