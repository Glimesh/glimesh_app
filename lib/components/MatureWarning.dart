import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class MatureWarning extends StatelessWidget {
  final void Function() onAccept;

  MatureWarning({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.t("Mature Content Warning"),
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          context.t(
              "The streamer has flagged this channel as only appropriate for Mature Audiences."),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Text(
          context.t("Do you wish to continue?"),
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Padding(
          child: OutlinedButton(
            child: Text(context.t("Agree & View Channel")),
            onPressed: onAccept,
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
        ElevatedButton(
          child: Text(context.t("Go Back")),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ));
  }
}
