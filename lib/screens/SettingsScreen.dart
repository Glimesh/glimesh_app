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
        child: _buildThemeSelector(context),
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
            setState(() {
              context
                  .read<SettingsBloc>()
                  .add(ChangeTheme(appTheme: newValue ?? ThemeMode.system));
            });
          },
        )
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
