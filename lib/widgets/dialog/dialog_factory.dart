import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/remote_support_bloc/remote_support_request_bloc.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/colors.dart' as app_colors;
import '../../utils/translator.dart';
import '../custom_text/custom_text.dart';
import 'dialogs.dart';

enum DialogType {
  info,
  error,
  confirmation,
  waitingForTechnician,
  upsInfo,
  languageSelection,
  recentUpsConnections
}

class DialogFactory {
  static getDialog(
      {required BuildContext context,
      required DialogType dialogType,
      String? title,
      String? description,
      VoidCallback? onButtonClicked}) {
    switch (dialogType) {
      case DialogType.info:
        return InfoDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.error:
        return ErrorDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.confirmation:
        return ConfirmationDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.waitingForTechnician:
        return WaitingForTechnicianDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.upsInfo:
        return UpsInfoDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.languageSelection:
        return LanguageSelectionDialog()
            .createDialog(context, title, description, onButtonClicked);
      case DialogType.recentUpsConnections:
        return RecentUpsConnectionsDialog()
            .createDialog(context, title, description, onButtonClicked);
    }
  }

  static void showQuitTheAppDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Quit',
              description:
                  'Are you sure you want to disconnect from the UPS and quit the app?',
              onButtonClicked: () {
                Navigator.pop(context);
                Navigator.pop(context);
              });
        });
  }

  static void showDisconnectFromUpsDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Disconnect from UPS',
              description: 'Are you sure you want to disconnect from the UPS?',
              onButtonClicked: () {
                context
                    .read<UpsConnectionHandlerBloc>()
                    .add(const DisconnectFromUps());
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "upsConnection", (Route<dynamic> route) => false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: CustomText(
                      Translator()
                          .translateIfExists("DISCONNECTED_FROM_THE_UPS"),
                      13.0.sp,
                      13.0.sp,
                      textAlign: TextAlign.center,
                      color: app_colors.white),
                  backgroundColor: app_colors.yellow,
                  duration: const Duration(seconds: 1),
                ));
              });
        });
  }

  static void showDisconnectedFromUpsDialog(
      {required BuildContext context,
      required String title,
      required String description,
      VoidCallback? onButtonClicked}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: DialogFactory.getDialog(
                context: context,
                dialogType: DialogType.error,
                title: title,
                description: description,
                onButtonClicked: onButtonClicked ??
                    () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "upsConnection", (Route<dynamic> route) => false);
                    }));
      },
    );
  }

  static void showCannotConnectToUpsDialog(
      {required BuildContext context,
      required String title,
      required String description,
      VoidCallback? onButtonClicked}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.error,
              title: title,
              description: description,
              onButtonClicked: onButtonClicked ??
                  () {
                    Navigator.pop(context);
                  });
        });
  }

  static Future<void> showProgressDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  static Future<int?> showSelectLanguageDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context, dialogType: DialogType.languageSelection);
        });
  }

  static void showLogoutDialog(BuildContext context,
      {required bool goBackToDashboard}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Logout',
              description: 'Are you sure you want to logout?',
              onButtonClicked: () {
                context.read<AuthenticationBloc>().add(const Logout());
                if (goBackToDashboard) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      "dashboard", (Route<dynamic> route) => false);
                } else {
                  Navigator.pop(context);
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: CustomText(
                      Translator().translateIfExists("YOU_LOGGED_OUT"),
                      13.0.sp,
                      13.0.sp,
                      textAlign: TextAlign.center,
                      color: app_colors.white),
                  backgroundColor: app_colors.blue,
                  duration: const Duration(seconds: 1),
                ));
              });
        });
  }

  static void showGoToLoginDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Not logged yet',
              description:
                  'To request remote support you must be logged in. Do you want to login?',
              onButtonClicked: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "login", (Route<dynamic> route) => false);
              });
        });
  }

  static void showUpsInfoDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context, dialogType: DialogType.upsInfo);
        });
  }

  static void showCannotInitializeAppErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: DialogFactory.getDialog(
                context: context,
                dialogType: DialogType.error,
                title: 'Cannot initialize app',
                description:
                    'An unexpected error occurred during app initialization',
                onButtonClicked: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }));
      },
    );
  }

  static void showLanguageInfoDialog(
      BuildContext context, String title, String description) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.info,
              title: Translator().translateIfExists('TITLE_LANGUAGE'),
              description:
                  'Choose the language for information regarding the UPS');
        });
  }

  static Future<int?> showSelectRecentUpsConnectionDialog(
      BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context, dialogType: DialogType.recentUpsConnections);
        });
  }

  static void showLoginFailedDialog(
      {required BuildContext context,
      required String title,
      required String description,
      VoidCallback? onButtonClicked}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.error,
              title: title,
              description: description,
              onButtonClicked: onButtonClicked ??
                  () {
                    Navigator.pop(context);
                  });
        });
  }
}
