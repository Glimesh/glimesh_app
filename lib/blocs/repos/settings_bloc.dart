import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glimesh_app/repository.dart';

@immutable
abstract class SettingsEvent extends Equatable {}

class InitSettingsData extends SettingsEvent {
  InitSettingsData();
  @override
  List<Object> get props => [];
}

class ChangeTheme extends SettingsEvent {
  final ThemeMode appTheme;

  ChangeTheme({required this.appTheme});

  @override
  List<Object> get props => [this.appTheme];
}

class ChangeLocale extends SettingsEvent {
  final Locale locale;

  ChangeLocale({required this.locale});

  @override
  List<Object> get props => [this.locale];
}

@immutable
abstract class SettingsState extends Equatable {}

class InitialState extends SettingsState {
  final ThemeMode theme;
  final Locale locale;

  InitialState({required this.theme, required this.locale});

  @override
  List<Object> get props => [theme, locale];
}

class ThemeChanged extends SettingsState {
  final ThemeMode newTheme;

  ThemeChanged(this.newTheme);

  @override
  List<Object> get props => [newTheme];
}

class LocaleChanged extends SettingsState {
  final Locale newLocale;

  LocaleChanged(this.newLocale);

  @override
  List<Object> get props => [newLocale];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late SettingsRepository repo;

  ThemeMode currentTheme = ThemeMode.system;
  Locale currentLocale = Locale("en");

  SettingsBloc()
      : super(InitialState(theme: ThemeMode.system, locale: Locale('en'))) {
    on<InitSettingsData>((_, emit) async {
      var prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs: prefs);
      currentTheme = await repo.getTheme();
      currentLocale = await repo.getLocale() ?? Locale('en');
      emit(InitialState(theme: currentTheme, locale: currentLocale));
    });
    on<ChangeTheme>((event, emit) async {
      currentTheme = event.appTheme;
      await repo.setTheme(currentTheme);
      emit(ThemeChanged(currentTheme));
    });
    on<ChangeLocale>((event, emit) async {
      currentLocale = event.locale;
      await repo.setLocale(currentLocale);
      emit(LocaleChanged(currentLocale));
    });
  }
}
