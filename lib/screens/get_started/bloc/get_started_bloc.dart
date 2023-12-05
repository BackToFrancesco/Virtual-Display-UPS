import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../../../utils/translator.dart';

part 'get_started_event.dart';

part 'get_started_state.dart';

class GetStartedBloc extends Bloc<GetStartedEvent, GetStartedState> {
  final Translator _translator = Translator();

  GetStartedBloc() : super(const GetStartedState()) {
    on<LanguageChanged>(_onLanguageChanged);
    on<Init>(_onInit);
  }

  Future<void> _onLanguageChanged(
      LanguageChanged event, Emitter<GetStartedState> emit) async {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    await prefs.setString('language', event.language);
    _translator.setTargetLanguageIfExists(event.language);
    emit(state.copyWith(language: event.language));
  }

  void _onInit(Init event, Emitter<GetStartedState> emit) {
    emit(state.copyWith(language: _translator.targetLanguage));
  }
}
