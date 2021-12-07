import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/components/ChannelCard.dart';

class FollowingScreen extends StatelessWidget {
  final GraphQLClient client;

  const FollowingScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => ChannelListBloc(
          glimeshRepository: GlimeshRepository(client: client),
        ),
        child: LiveFollowedChannelsWidget(),
      ),
    );
  }
}

class LiveFollowedChannelsWidget extends StatelessWidget {
  LiveFollowedChannelsWidget();

  @override
  Widget build(BuildContext context) {
    ChannelListBloc bloc = BlocProvider.of<ChannelListBloc>(context);
    bloc.add(LoadMyLiveFollowedChannels());

    return RefreshIndicator(
        child: BlocBuilder<ChannelListBloc, ChannelListState>(
            bloc: bloc,
            builder: (BuildContext context, ChannelListState state) {
              if (state is ChannelListLoading) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: "Loading ...",
                    ),
                  ),
                );
              }

              if (state is ChannelListNotLoaded) {
                return Text("Error loading channels");
              }

              if (state is ChannelListLoaded) {
                final List<Channel> channels = state.results;

                if (channels.length == 0) {
                  return Center(
                      child: Text("No live channels in this category"));
                }

                return ListView.builder(
                  itemCount: channels.length,
                  itemBuilder: (BuildContext context, int index) => InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/channel',
                        arguments: channels[index],
                      );
                    },
                    // Generally, material cards use onSurface with 12% opacity for the pressed state.
                    splashColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.12),
                    // Generally, material cards do not have a highlight overlay.
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: ChannelCard(channel: channels[index]),
                    ),
                  ),
                );
              }

              return Text("Unexpected");
            }),
        onRefresh: () async {
          bloc.add(LoadMyLiveFollowedChannels());
        });
  }
}
