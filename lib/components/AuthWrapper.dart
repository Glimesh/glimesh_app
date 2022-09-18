import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/blocs/repos/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  AuthWrapper({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, state) {
      if (state is AuthFailure) {
        return const MaterialApp(
            home: Scaffold(
                body: Text(
                    "Failed to authenticate - check your internet connection and try again.")));
      }

      if (state is AuthClientAcquired) return child;

      // state is AuthInitial, AuthLoading or else
      return MaterialApp(
          home: Scaffold(
              body: Padding(
                  padding: const EdgeInsets.only(top: 60, bottom: 60),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child:
                              Image.asset('assets/images/logo-with-text.png'),
                        ),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 40, left: 40, right: 40),
                          child: Loading("Loading"),
                        ),
                      ),
                      _versionWidget(),
                    ],
                  ))));
    });
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
}
