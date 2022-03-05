import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

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
        child: Text("Settings page"),
        margin: EdgeInsets.all(4),
      ),
    );
  }
}
