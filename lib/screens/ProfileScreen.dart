import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class UserProfileScreen extends StatelessWidget {
  final String username;

  const UserProfileScreen({required this.username}) : super();

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of<UserBloc>(context);
    bloc.add(LoadUser(username: username));

    return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: BlocBuilder(
            bloc: bloc,
            builder: (BuildContext context, UserState state) {
              return ProfileWidget(userState: state);
            }));
  }
}

class MyProfileScreen extends StatelessWidget {
  final GraphQLClient client;

  const MyProfileScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocProvider(
        create: (context) => UserBloc(
          glimeshRepository: GlimeshRepository(client: client),
        ),
        child: _MyProfileWidget(),
      ),
    );
  }
}

// this is intentionally a bit hacky, but it works
class _MyProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of<UserBloc>(context);
    bloc.add(LoadMyself());

    return BlocBuilder(
        bloc: bloc,
        builder: (BuildContext context, UserState state) {
          return ProfileWidget(userState: state);
        });
  }
}

class ProfileWidget extends StatelessWidget {
  final UserState userState;

  const ProfileWidget({required this.userState}) : super();

  @override
  Widget build(BuildContext context) {
    if (userState is UserLoading) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: "Loading ...",
          ),
        ),
      );
    }

    if (userState is UserNotLoaded) {
      return Text("Error loading user");
    }
    if (userState is UserLoaded) {
      User user = (userState as UserLoaded).user;

      return Center(
        child: Text("${user.username} :)"),
      );
    }

    return Text("Unexpected");
  }
}
