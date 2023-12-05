import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../../../utils/translator.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Translator _translator = Translator();

  SettingsBloc() : super(const SettingsState()) {
    on<LanguageChanged>(_onLanguageChanged);
    on<Init>(_onInit);
  }

  Future<void> _onLanguageChanged(
      LanguageChanged event, Emitter<SettingsState> emit) async {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    await prefs.setString('language', event.language);
    _translator.setTargetLanguageIfExists(event.language);
    emit(state.copyWith(language: event.language));
  }

  void _onInit(Init event, Emitter<SettingsState> emit) {
    emit(state.copyWith(language: _translator.targetLanguage));
  }
}
