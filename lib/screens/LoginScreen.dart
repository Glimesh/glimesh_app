import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/auth_bloc.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/track/track.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    track.event(page: "users/log_in");

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            horizontalTablet
                ? _buildHorizontal(context)
                : _buildVertical(context),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                ),
              ),
              onTap: () => Navigator.pop(context),
            )
          ],
        ),
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
            _versionWidget(),
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
        _versionWidget()
      ],
    );
  }

  Widget _versionWidget() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                style: Theme.of(context).textTheme.caption,
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }

  Widget _logo() {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Image.asset('assets/images/logo-with-text.png'),
    );
  }

  Widget _loginButton(BuildContext context, bool center) {
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
                context.read<AuthBloc>().add(UserLoggedIn(client: client));

                // Later once "state" is figured out, this can be just .pop to go back to the last page
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text(context.t("Login or Register")),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
        ],
      ),
    );
  }
}
