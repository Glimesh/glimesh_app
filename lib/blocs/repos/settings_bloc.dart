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

class ChangeBypassMatureWarning extends SettingsEvent {
  final bool shouldBypass;

  ChangeBypassMatureWarning({required this.shouldBypass});

  @override
  List<Object> get props => [this.shouldBypass];
}

@immutable
abstract class SettingsState extends Equatable {}

class InitialState extends SettingsState {
  final ThemeMode theme;
  final Locale locale;
  final bool bypassMatureWarning;

  InitialState(
      {required this.theme,
      required this.locale,
      required this.bypassMatureWarning});

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

class BypassMatureWarningChanged extends SettingsState {
  final bool shouldBypass;

  BypassMatureWarningChanged(this.shouldBypass);

  @override
  List<Object> get props => [this.shouldBypass];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late SettingsRepository repo;

  ThemeMode currentTheme = ThemeMode.system;
  Locale currentLocale = Locale("en");
  bool bypassMatureWarning = false;

  SettingsBloc()
      : super(InitialState(
            theme: ThemeMode.system,
            locale: Locale('en'),
            bypassMatureWarning: false)) {
    on<InitSettingsData>((_, emit) async {
      var prefs = await SharedPreferences.getInstance();

      repo = SettingsRepository(prefs: prefs);

      currentTheme = await repo.getTheme();
      currentLocale = await repo.getLocale() ?? Locale('en');
      bypassMatureWarning = await repo.getShouldBypassMatureWarning();

      emit(InitialState(
          theme: currentTheme,
          locale: currentLocale,
          bypassMatureWarning: bypassMatureWarning));
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

    on<ChangeBypassMatureWarning>((event, emit) async {
      bypassMatureWarning = event.shouldBypass;
      await repo.setShouldBypassMatureWarning(bypassMatureWarning);
      emit(BypassMatureWarningChanged(bypassMatureWarning));
    });
  }
}
