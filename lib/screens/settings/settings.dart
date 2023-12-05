import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../utils/translator.dart';
import '../../widgets/dialog/dialog_factory.dart';
import '../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../widgets/custom_text/custom_text.dart';
import '../../config/colors.dart' as app_colors;
import 'bloc/settings_bloc.dart';

bool _isMenuOpened = false;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (BuildContext ctx) => SettingsBloc()..add(const Init()),
      child: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_isMenuOpened) {
            return Future.value(true);
          } else {
            DialogFactory.showQuitTheAppDialog(context);
            return Future.value(false);
          }
        },
        child: BlocListener<UpsConnectionHandlerBloc,
                UpsConnectionHandlerState>(
            listener: (context, state) {
              if ([
                UpsConnectionStatus.disconnectedDueToIllegalAddress,
                UpsConnectionStatus.disconnectedDueToIllegalFunction,
                UpsConnectionStatus.disconnectedDueToInvalidData,
                UpsConnectionStatus.disconnectedDueToConnectorError,
                UpsConnectionStatus.disconnectedDueToUnknownErrorCode
              ].contains(state.upsConnectionStatus)) {
                DialogFactory.showDisconnectedFromUpsDialog(
                    context: context,
                    title: state.errorTitle!,
                    description: state.errorDescription!);
              }
            },
            child: BlocBuilder<SettingsBloc, SettingsState>(
                buildWhen: (previous, current) =>
                    previous.language != current.language,
                builder: (context, state) {
                  return Scaffold(
                      onDrawerChanged: (isOpened) {
                        _isMenuOpened = isOpened;
                      },
                      drawer: NavigationDrawer(pageNumber: 10),
                      appBar: CustomAppBar(
                          title: _translator.translateIfExists("SETTINGS")),
                      body: SafeArea(child: SingleChildScrollView(
                          child: Column(
                        children: [
                          getSettingsMenuItem(
                              title: _translator.translateIfExists("LANGUAGE"),
                              subtitle: state.language,
                              onTap: () {
                                DialogFactory.showSelectLanguageDialog(context)
                                    .then((index) {
                                  if (index != null) {
                                    context.read<SettingsBloc>().add(
                                        LanguageChanged(
                                            _translator.getLanguages()[index]));
                                  }
                                });
                              }),
                          const Divider(
                            height: 5,
                            color: app_colors.grey,
                          ),
                        ],
                      ))));
                })));
  }

  Widget getSettingsMenuItem(
      {required String title,
      String? subtitle,
      IconData icon = Icons.arrow_forward_ios,
      required VoidCallback onTap}) {
    return ListTile(
        trailing: Icon(
          icon,
          size: 2.8.h,
        ),
        title: CustomText(title, 14.0.sp, 14.0.sp, color: app_colors.black),
        subtitle: subtitle != null
            ? CustomText(subtitle, 10.0.sp, 10.0.sp,
                color: app_colors.socomecBlue)
            : null,
        onTap: onTap);
  }
}
