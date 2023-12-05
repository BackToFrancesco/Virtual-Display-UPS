import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import '../../../repositories/authentication_repository/authentication_repository.dart';
import '../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../../../utils/translator.dart';

part 'splash_screen_event.dart';

part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc(
      BuildContext context, AuthenticationRepository authenticationRepository)
      : super(const SplashScreenState()) {
    _authenticationRepository = authenticationRepository;
    on<SplashScreenCreated>(_onSplashScreenCreated);
    _localeLanguage = LocaleNames.of(context)!
        .nameOf(Localizations.localeOf(context).languageCode);
    if (_localeLanguage != null) {
      _localeLanguage = _localeLanguage![0].toUpperCase() +
          _localeLanguage!.substring(1).toLowerCase();
    }
    add(const SplashScreenCreated());
  }

  late final AuthenticationRepository _authenticationRepository;

  late String? _localeLanguage;

  Future<void> _onSplashScreenCreated(
      SplashScreenCreated event, Emitter<SplashScreenState> emit) async {
    try {
      await Translator.init();

      await shared_preferences_global.init();

      _authenticationRepository.init();

      final SharedPreferences prefs =
          shared_preferences_global.sharedPreferences;

      final bool firstLaunch = prefs.getBool('firstLaunch') ?? true;
      final String language =
          prefs.getString('language') ?? _localeLanguage ?? "English";
      Translator().setTargetLanguageIfExists(language);

      if (firstLaunch) {
        emit(state.copyWith(initialized: true, nextRouteName: "getStarted"));
      } else {
        emit(state.copyWith(initialized: true, nextRouteName: "upsConnection"));
      }
    } catch (e) {
      emit(state.copyWith(initialized: false));
    }
  }
}
