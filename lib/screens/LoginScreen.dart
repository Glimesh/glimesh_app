import 'package:flutter/material.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/auth.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class LoginScreen extends StatelessWidget {
  AuthState? authState;

  @override
  Widget build(BuildContext context) {
    authState = AuthState.of(context);
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    return Scaffold(
      body: SafeArea(
        child: horizontalTablet
            ? _buildHorizontal(context)
            : _buildVertical(context),
      ),
    );
  }

  Widget _buildVertical(context) {
    return Padding(
        padding: EdgeInsets.only(top: 60, bottom: 60),
        child: Column(
          children: [
            Expanded(
              child: _logo(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 40, left: 40, right: 40),
                child: _loginButton(context, true),
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                      ),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),
          ],
        ));
  }

  Widget _buildHorizontal(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _logo(),
        ),
        Expanded(
          child: _loginButton(context, false),
        ),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                  ),
                );
              default:
                return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget _logo() {
    return Image.asset('assets/images/logo-with-text.png');
  }

  Widget _loginButton(BuildContext context, bool center) {
    if (authState == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            "${context.t("Next-Gen")} ${context.t("Live Streaming!")}",
            style: Theme.of(context).textTheme.headline4,
            // style: TextStyle(fontSize: 20),
            maxLines: 1,
          ),
          AutoSizeText(
            context.t(
                "The first live streaming platform built around truly real time interactivity. Our streams are warp speed, our chat is blazing, and our community is thriving."),
            style: Theme.of(context).textTheme.subtitle1,
            textAlign: center ? TextAlign.center : TextAlign.left,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                GraphQLClient client = await Glimesh.client();
                authState!.login(client);

                // Later once "state" is figured out, this can be just .pop to go back to the last page
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text(context.t("Login")),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          Center(
            child: Text(
              context.t(
                  "If you need to register, please visit Glimesh.tv on your phone or computer."),
              textAlign: center ? TextAlign.center : TextAlign.left,
            ),
          )
        ],
      ),
    );
  }
}
