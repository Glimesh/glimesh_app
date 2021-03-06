import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/settings_bloc.dart';
import 'package:glimesh_app/i18n.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsWidget();
  }
}

class SettingsWidget extends StatefulWidget {
  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('Settings'))),
      body: Container(
        child: Column(children: [
          _buildThemeSelector(context),
          _buildLocaleSelector(context),
          _buildMatureWarningToggle(context),
        ]),
        margin: EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Row(
      children: [
        Text(context.t("Theme")),
        DropdownButton<ThemeMode>(
          value: context.select((SettingsBloc bloc) => bloc.currentTheme),
          items: <DropdownMenuItem<ThemeMode>>[
            DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(context.t("System Theme"))),
            DropdownMenuItem(
                value: ThemeMode.light, child: Text(context.t("Light"))),
            DropdownMenuItem(
                value: ThemeMode.dark, child: Text(context.t("Dark"))),
          ],
          onChanged: (ThemeMode? newValue) {
            context
                .read<SettingsBloc>()
                .add(ChangeTheme(appTheme: newValue ?? ThemeMode.system));
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildLocaleSelector(BuildContext context) {
    final localeList = supportedLocales
        .map((locale) => DropdownMenuItem(
            value: locale,
            child: Text(languages[locale.toString()] ?? locale.toString())))
        .toList();

    return Row(
      children: [
        Text(context.t("Language")),
        DropdownButton<Locale>(
            items: localeList,
            value: context.select((SettingsBloc bloc) => bloc.currentLocale),
            onChanged: (Locale? newLocale) {
              context
                  .read<SettingsBloc>()
                  .add(ChangeLocale(locale: newLocale ?? Locale('en')));
            }),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget _buildMatureWarningToggle(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(context.t("Bypass Mature Content Warning")),
      Switch(
        value: context.select((SettingsBloc bloc) => bloc.bypassMatureWarning),
        onChanged: (newVal) {
          context
              .read<SettingsBloc>()
              .add(ChangeBypassMatureWarning(shouldBypass: newVal));
        },
      ),
    ]);
  }
}
