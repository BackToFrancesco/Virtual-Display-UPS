import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formz/formz.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../config/colors.dart' as app_colors;
import '../../repositories/authentication_repository/models/authentication_manager/authentication_manager.dart';
import '../../repositories/authentication_repository/models/user.dart';
import 'bloc/login_bloc.dart';

bool _isMenuOpened = false;
bool _loginInProgress = false;
bool _disconnectedFromUps = false;

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (BuildContext context) =>
          LoginBloc(authenticationBloc: context.read<AuthenticationBloc>()),
      child: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (!_loginInProgress) {
            if (_isMenuOpened) {
              return Future.value(true);
            } else {
              DialogFactory.showQuitTheAppDialog(context);
              return Future.value(false);
            }
          }
          return Future.value(false);
        },
        child:
            BlocListener<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
                listener: (context, state) {
                  if ([
                    UpsConnectionStatus.disconnectedDueToIllegalAddress,
                    UpsConnectionStatus.disconnectedDueToIllegalFunction,
                    UpsConnectionStatus.disconnectedDueToInvalidData,
                    UpsConnectionStatus.disconnectedDueToConnectorError,
                    UpsConnectionStatus.disconnectedDueToUnknownErrorCode
                  ].contains(state.upsConnectionStatus)) {
                    _disconnectedFromUps = true;
                    if (_loginInProgress) {
                      Navigator.pop(context);
                    }
                    DialogFactory.showDisconnectedFromUpsDialog(
                        context: context,
                        title: state.errorTitle!,
                        description: state.errorDescription!);
                  }
                },
                child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Scaffold(
                      onDrawerChanged: (isOpened) {
                        _isMenuOpened = isOpened;
                      },
                      drawer: NavigationDrawer(pageNumber: 12),
                      appBar: CustomAppBar(
                          title: _translator.translateIfExists("LOGIN")),
                      body: SafeArea(child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            getLoginForm(context),
                            SizedBox(height: 8.0.h),
                            getImage(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),),
                    ))));
  }

  Widget getImage() {
    return SvgPicture.asset(
      'assets/images/login/login.svg',
      height: (SizerUtil.deviceType == DeviceType.mobile ? 35.0.w : 30.0.w),
      width: (SizerUtil.deviceType == DeviceType.mobile ? 35.0.w : 30.0.w),
    );
  }

  void handleLoginSuccess({required BuildContext context}) {
    final User? user = context.read<AuthenticationBloc>().user;
    Navigator.of(context)
        .pushNamedAndRemoveUntil("dashboard", (Route<dynamic> route) => false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: CustomText(
          _translator.translateIfExists("Welcome") +
              " ${user!.name} ${user.surname}",
          13.0.sp,
          13.0.sp,
          textAlign: TextAlign.center,
          color: app_colors.white),
      backgroundColor: app_colors.blue,
      duration: const Duration(seconds: 1),
    ));
  }

  Widget getLoginForm(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
          if (state.authenticationStatus == AuthenticationStatus.logged) {
            if (!_disconnectedFromUps) {
              context.read<LoginBloc>().add(const SubmissionSuccess());
              handleLoginSuccess(context: context);
            }
          } else {
            if (!_disconnectedFromUps) {
              _loginInProgress = false;
              Navigator.pop(context);
              context.read<LoginBloc>().add(const SubmissionFailure());
              DialogFactory.showLoginFailedDialog(
                  context: context,
                  title: state.errorTitle!,
                  description: state.errorDescription!);
            }
          }
        }),
        BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) =>
              current.status == FormzStatus.submissionInProgress,
          listener: (context, state) {
            DialogFactory.showProgressDialog(context);
          },
        ),
      ],
      child: Form(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: app_colors.lightGrey,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: (MediaQuery.of(context).orientation == Orientation.portrait
              ? (SizerUtil.deviceType == DeviceType.mobile
                  ? EdgeInsets.fromLTRB(15.0.w, 5.0.h, 15.0.w, 0.0.h)
                  : EdgeInsets.fromLTRB(25.0.w, 5.0.h, 25.0.w, 0.0.h))
              : EdgeInsets.fromLTRB(40.0.w, 5.0.h, 40.0.w, 0.0.h)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(7, 0, 0, 5),
                  child: CustomText(
                      _translator.translateIfExists("EMAIL"), 14.0.sp, 2.0.h,
                      bold: true)),
              getEmailInput(),
              Container(
                  padding: const EdgeInsets.fromLTRB(7, 12, 0, 5),
                  child: CustomText(
                      _translator.translateIfExists("PASSWORD"), 14.0.sp, 2.0.h,
                      bold: true)),
              getPasswordInput(),
              SizedBox(height: 2.0.h),
              Align(
                child: getLoginButton(),
              ),
              SizedBox(
                  height:
                      SizerUtil.deviceType == DeviceType.mobile ? null : 0.5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget getEmailInput() {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => (previous.email != current.email),
        builder: (context, state) {
          return TextField(
            style: TextStyle(
                fontSize: (SizerUtil.deviceType == DeviceType.mobile
                    ? 12.0.sp
                    : 2.0.h)),
            onChanged: (email) =>
                context.read<LoginBloc>().add(EmailChanged(email)),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                    fontSize: (SizerUtil.deviceType == DeviceType.mobile
                        ? 10.0.sp
                        : 1.5.h)),
                errorText: state.email.invalid ? 'Invalid email' : null,
                contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 6),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: app_colors.lightLightGrey),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                )),
          );
        });
  }

  Widget getPasswordInput() {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) =>
            (previous.password != current.password),
        builder: (context, state) {
          return TextField(
            obscureText: true,
            style: TextStyle(
                fontSize: (SizerUtil.deviceType == DeviceType.mobile
                    ? 12.0.sp
                    : 2.0.h)),
            onChanged: (password) =>
                context.read<LoginBloc>().add(PasswordChanged(password)),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                    fontSize: (SizerUtil.deviceType == DeviceType.mobile
                        ? 10.0.sp
                        : 1.5.h)),
                errorText: state.password.invalid ? 'Invalid password' : null,
                contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 6),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: app_colors.lightLightGrey),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                )),
          );
        });
  }

  Widget getLoginButton() {
    return BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return ElevatedButton(
            child: CustomText(
                _translator.translateIfExists("Login"), null, 9.0.sp,
                color: app_colors.white),
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: state.status.isValidated &&
                    !state.status.isSubmissionInProgress &&
                    !state.status.isSubmissionSuccess
                ? () {
                    _loginInProgress = true;
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.read<LoginBloc>().add(const Submitted());
                  }
                : null,
          );
        });
  }
}
