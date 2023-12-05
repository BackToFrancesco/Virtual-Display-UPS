import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../config/colors.dart' as app_colors;
import 'package:flutter_svg/flutter_svg.dart';
import '../../repositories/authentication_repository/models/authentication_manager/authentication_manager.dart';
import '../../repositories/authentication_repository/models/user.dart';
import '../../utils/translator.dart';
import '../dialog/dialog_factory.dart';
import '../../widgets/custom_text/custom_text.dart';

class NavigationDrawer extends StatelessWidget {
  final Translator _translator = Translator();
  final int pageNumber;

  NavigationDrawer({Key? key, required this.pageNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        buildWhen: (previous, current) =>
            current.authenticationStatus == AuthenticationStatus.loggedOut,
        builder: (context, state) {
          final User? user = context.read<AuthenticationBloc>().user;
          final bool logged = context.read<AuthenticationBloc>().logged;
          return SizedBox(
              width: 80.w,
              child: Drawer(
                  child: Material(
                child: ListView(
                  padding: const EdgeInsets.all(0.0),
                  children: <Widget>[
                    _buildHeader(
                      logged: logged,
                      name: user?.name,
                      surname: user?.surname,
                      onClicked: () {
                        _selectedItem(context, logged ? 13 : 12);
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            text: _translator.translateIfExists("DASHBOARD"),
                            icon: Icons.dashboard,
                            onClicked: () {
                              _selectedItem(context, 0);
                            },
                            isAlreadyIn: pageNumber == 0 ? true : false,
                          ),
                          const Divider(
                            color: app_colors.grey,
                          ),
                          _buildMenuItem(
                            text: _translator.translateIfExists("UPS_STATES"),
                            icon: Icons.content_paste,
                            onClicked: () {
                              _selectedItem(context, 1);
                            },
                            isAlreadyIn: pageNumber == 1 ? true : false,
                          ),
                          _buildMenuItem(
                            text: _translator.translateIfExists("UPS_ALARMS"),
                            icon: Icons.warning_amber_sharp,
                            onClicked: () {
                              _selectedItem(context, 2);
                            },
                            isAlreadyIn: pageNumber == 2 ? true : false,
                          ),
                          _buildExpandable(
                              context: context,
                              text: _translator
                                  .translateIfExists("UPS_MEASUREMENTS_MENU"),
                              icon: Icons.show_chart),
                          const Divider(
                            color: app_colors.grey,
                          ),
                          _buildMenuItem(
                            text:
                                _translator.translateIfExists('REMOTE_SUPPORT'),
                            icon: Icons.contact_support_outlined,
                            onClicked: () {
                              _selectedItem(context, 8);
                            },
                            isAlreadyIn: pageNumber == 8 ? true : false,
                          ),
                          _buildMenuItem(
                            text: _translator
                                .translateIfExists('DISCONNECT_FROM_UPS'),
                            icon: Icons.cable,
                            onClicked: () {
                              _selectedItem(context, 9);
                            },
                            isAlreadyIn: pageNumber == 9 ? true : false,
                          ),
                          const Divider(
                            color: app_colors.grey,
                          ),
                          if (!logged)
                            _buildMenuItem(
                              text: _translator.translateIfExists('LOGIN'),
                              icon: Icons.login,
                              onClicked: () {
                                _selectedItem(context, 12);
                              },
                              isAlreadyIn: pageNumber == 12 ? true : false,
                            ),
                          if (logged)
                            _buildMenuItem(
                              text: _translator
                                  .translateIfExists('PERSONAL_DATA'),
                              icon: Icons.account_circle,
                              onClicked: () {
                                _selectedItem(context, 13);
                              },
                              isAlreadyIn: pageNumber == 13 ? true : false,
                            ),
                          if (logged)
                            _buildMenuItem(
                              text: _translator.translateIfExists('LOGOUT'),
                              icon: Icons.logout,
                              onClicked: () {
                                _selectedItem(context, 14);
                              },
                              isAlreadyIn: pageNumber == 14 ? true : false,
                            ),
                          const Divider(
                            color: app_colors.grey,
                          ),
                          _buildMenuItem(
                            text: _translator.translateIfExists('SETTINGS'),
                            icon: Icons.settings_outlined,
                            onClicked: () {
                              _selectedItem(context, 10);
                            },
                            isAlreadyIn: pageNumber == 10 ? true : false,
                          ),
                          _buildMenuItem(
                            text: _translator.translateIfExists('QUIT'),
                            icon: Icons.directions_run_sharp,
                            onClicked: () {
                              _selectedItem(context, 11);
                            },
                            isAlreadyIn: pageNumber == 11 ? true : false,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )));
        });
  }

  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required VoidCallback? onClicked,
    required bool isAlreadyIn,
  }) {
    return ListTile(
        tileColor: isAlreadyIn ? app_colors.lightLightLightGrey : null,
        leading: Icon(
          icon,
          size: 3.0.h,
          color: isAlreadyIn ? app_colors.blue : app_colors.black,
        ),
        title: CustomText(text, 12.0.sp, 12.0.sp,
            color: isAlreadyIn ? app_colors.blue : app_colors.black),
        onTap: onClicked);
  }

  Widget _buildExpandableItem(
      {required String text,
      required VoidCallback? onClicked,
      required bool isAlreadyIn}) {
    return ListTile(
      tileColor: isAlreadyIn ? app_colors.lightLightLightGrey : null,
      title: CustomText(text, 12.0.sp, 12.0.sp,
          color: isAlreadyIn ? app_colors.blue : app_colors.black),
      onTap: onClicked,
    );
  }

  Widget _buildExpandable(
      {required BuildContext context,
      required String text,
      required IconData icon}) {
    return Theme(
        data: Theme.of(context).copyWith(iconTheme: IconThemeData(size: 3.0.h)),
        child: ExpansionTile(
          initiallyExpanded:
              [3, 4, 5, 6, 7].contains(pageNumber) ? true : false,
          iconColor: app_colors.black,
          childrenPadding: const EdgeInsets.only(left: 57),
          leading: Icon(icon, size: 3.0.h),
          title: CustomText(text, 12.0.sp, 12.0.sp),
          children: [
            _buildExpandableItem(
              text: _translator.translateIfExists('BYPASS_FIRMWARE_VERSION'),
              onClicked: () {
                _selectedItem(context, 3);
              },
              isAlreadyIn: pageNumber == 3 ? true : false,
            ),
            const Divider(
              color: app_colors.grey,
            ),
            _buildExpandableItem(
              text: _translator.translateIfExists('BOOST_FIRMWARE_VERSION'),
              onClicked: () {
                _selectedItem(context, 4);
              },
              isAlreadyIn: pageNumber == 4 ? true : false,
            ),
            const Divider(
              color: app_colors.grey,
            ),
            _buildExpandableItem(
              text: _translator.translateIfExists('BATTERIES_VIEW'),
              onClicked: () {
                _selectedItem(context, 5);
              },
              isAlreadyIn: pageNumber == 5 ? true : false,
            ),
            const Divider(
              color: app_colors.grey,
            ),
            _buildExpandableItem(
              text: _translator.translateIfExists('INVERTER_FIRMWARE_VERSION'),
              onClicked: () {
                _selectedItem(context, 6);
              },
              isAlreadyIn: pageNumber == 6 ? true : false,
            ),
            const Divider(
              color: app_colors.grey,
            ),
            _buildExpandableItem(
              text: _translator.translateIfExists('OUTPUT'),
              onClicked: () {
                _selectedItem(context, 7);
              },
              isAlreadyIn: pageNumber == 7 ? true : false,
            ),
          ],
        ));
  }

  void _selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    if (pageNumber != index) {
      switch (index) {
        case 0:
          {
            Navigator.of(context).pushReplacementNamed("dashboard");
          }
          break;
        case 1:
          {
            Navigator.of(context).pushReplacementNamed("states");
          }
          break;
        case 2:
          {
            Navigator.of(context).pushReplacementNamed("alarms");
          }
          break;
        case 3:
          {
            Navigator.of(context).pushReplacementNamed("bypassMeasurements");
          }
          break;
        case 4:
          {
            Navigator.of(context).pushReplacementNamed("inputMeasurements");
          }
          break;
        case 5:
          {
            Navigator.of(context).pushReplacementNamed("batteryMeasurements");
          }
          break;
        case 6:
          {
            Navigator.of(context).pushReplacementNamed("inverterMeasurements");
          }
          break;
        case 7:
          {
            Navigator.of(context).pushReplacementNamed("outputMeasurements");
          }
          break;
        case 8:
          {
            Navigator.of(context).pushReplacementNamed("remoteSupportRequest");
          }
          break;
        case 9:
          {
            DialogFactory.showDisconnectFromUpsDialog(context);
          }
          break;
        case 10:
          {
            Navigator.of(context).pushReplacementNamed("settings");
          }
          break;
        case 11:
          {
            DialogFactory.showQuitTheAppDialog(context);
          }
          break;
        case 12:
          {
            Navigator.of(context).pushReplacementNamed("login");
          }
          break;
        case 13:
          {
            Navigator.of(context).pushReplacementNamed("personalData");
          }
          break;
        case 14:
          {
            DialogFactory.showLogoutDialog(context,
                goBackToDashboard: pageNumber == 13);
          }
      }
    }
  }

  Widget _buildHeader({
    required bool logged,
    required String? name,
    required String? surname,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 60, 25, 35),
          color: app_colors.socomecBlueLight,
          child: Row(
            children: [
              CircleAvatar(
                radius:
                    SizerUtil.deviceType == DeviceType.mobile ? 4.7.h : 4.0.h,
                child: SvgPicture.asset(
                  'assets/images/navigation_drawer/user_icon.svg',
                  height: 100.0.w,
                  width: 100.0.w,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(logged ? name! : 'Not logged yet', 2.7.h, 2.5.h,
                      color: app_colors.white),
                  if (logged)
                    CustomText(surname!, 2.7.h, 2.5.h, color: app_colors.white)
                ],
              ))
            ],
          ),
        ),
      );
}
