import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors.dart' as app_colors;
import '../../repositories/authentication_repository/authentication_repository.dart';
import '../../widgets/dialog/dialog_factory.dart';
import 'bloc/splash_screen_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashScreenBloc>(
      create: (BuildContext ctx) =>
          SplashScreenBloc(context, context.read<AuthenticationRepository>()),
      child: const SplashScreenPage(),
    );
  }
}

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashScreenBloc, SplashScreenState>(
        listener: (context, state) {
          if (state.initialized) {
            if (state.nextRouteName == "upsConnection") {
              Navigator.of(context).pushReplacementNamed("upsConnection");
            } else {
              Navigator.of(context).pushReplacementNamed("getStarted");
            }
          } else {
            DialogFactory.showCannotInitializeAppErrorDialog(context);
          }
        },
        child: const Scaffold(
          body: SafeArea(child: Center(
              child: CircularProgressIndicator(
                  color: app_colors.socomecBlueLight))),
        ));
  }
}
