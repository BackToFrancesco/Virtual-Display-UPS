import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:sizer/sizer.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'blocs/remote_support_bloc/remote_support_request_bloc.dart';
import 'blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import 'config/app_router.dart';
import 'config/themes.dart';
import 'repositories/authentication_repository/authentication_repository.dart';
import 'repositories/modbus_data_repository/modbus_repository.dart';
import 'repositories/remote_support_request_repository/remote_support_request_repository.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ModbusRepository>(
          create: (context) => ModbusRepository(),
        ),
        RepositoryProvider<AuthenticationRepository>(
          create: (context) => AuthenticationRepository(),
        ),
        RepositoryProvider<RemoteSupportRequestRepository>(
          create: (context) => RemoteSupportRequestRepository(
              modbusRepository:
                  RepositoryProvider.of<ModbusRepository>(context),
              authenticationRepository:
                  RepositoryProvider.of<AuthenticationRepository>(context)),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UpsConnectionHandlerBloc>(
              create: (BuildContext context) => UpsConnectionHandlerBloc(
                  modbusDataRepository:
                      RepositoryProvider.of<ModbusRepository>(context))),
          BlocProvider<AuthenticationBloc>(
              create: (BuildContext context) => AuthenticationBloc(
                  authenticationRepository:
                      RepositoryProvider.of<AuthenticationRepository>(
                          context))),
          BlocProvider<RemoteSupportRequestBloc>(
              create: (BuildContext context) => RemoteSupportRequestBloc(
                  remoteSupportRequestRepository:
                      RepositoryProvider.of<RemoteSupportRequestRepository>(
                          context)))
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                LocaleNamesLocalizationsDelegate(),
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('it'),
                Locale('fr'),
                Locale('de'),
                Locale('es'),
                Locale('ru'),
                Locale('lt'),
                Locale('zh'),
                Locale('zt'),
                Locale('sv'),
                Locale('tr'),
                Locale('pt'),
                Locale('cs'),
                Locale('pl'),
                Locale('fi'),
                Locale('et'),
                Locale('lv'),
                Locale('no'),
                Locale('sl'),
                Locale('sk'),
                Locale('hu'),
                Locale('ro'),
                Locale('nl'),
              ],
              title: 'Smart4energy',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.lightTheme,
              initialRoute: 'splashScreen',
              onGenerateRoute: AppRouter().onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
