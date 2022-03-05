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

@immutable
abstract class SettingsState extends Equatable {}

class InitialState extends SettingsState {
  final ThemeMode theme;

  InitialState({required this.theme});

  @override
  List<Object> get props => [theme];
}

class ThemeChanged extends SettingsState {
  final ThemeMode newTheme;

  ThemeChanged(this.newTheme);

  @override
  List<Object> get props => [newTheme];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  late SettingsRepository repo;

  ThemeMode currentTheme = ThemeMode.system;

  SettingsBloc() : super(InitialState(theme: ThemeMode.system)) {
    on<InitSettingsData>((_, emit) async {
      var prefs = await SharedPreferences.getInstance();
      repo = SettingsRepository(prefs: prefs);
      currentTheme = await repo.getTheme();
      emit(InitialState(theme: currentTheme));
    });
    on<ChangeTheme>((event, emit) async {
      currentTheme = event.appTheme;
      await repo.setTheme(currentTheme);
      emit(ThemeChanged(currentTheme));
    });
  }
}
