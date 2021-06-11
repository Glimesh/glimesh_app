import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class FollowingScreen extends StatelessWidget {
  final GraphQLClient client;

  const FollowingScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BlocProvider(
        create: (context) => UserBloc(
          glimeshRepository: GlimeshRepository(client: client),
        ),
        child: FollowingWidget(),
      ),
    );
  }
}

class FollowingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of<UserBloc>(context);
    bloc.add(LoadMyself());

    return BlocBuilder(
      bloc: bloc,
      builder: (BuildContext context, UserState state) {
        if (state is UserLoading) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: "Loading ...",
              ),
            ),
          );
        }

        if (state is UserNotLoaded) {
          print(state.errors);
          return Text("Error loading user");
        }
        if (state is UserLoaded) {
          User user = state.user;

          return Center(
            child: Text("Showing following for ${user.username} :)"),
          );
        }

        return Text("Unexpected");
      },
    );
  }
}
