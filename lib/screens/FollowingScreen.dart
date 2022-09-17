import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/auth_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:glimesh_app/components/ChannelList.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/models.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:glimesh_app/track.dart';

class FollowingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthClientAcquired;

    track.event(page: "streams/following");

    return Scaffold(
      body: BlocProvider(
        create: (context) => ChannelListBloc(
          glimeshRepository: GlimeshRepository(client: authState.client),
        ),
        child: LiveFollowedChannelsWidget(),
      ),
    );
  }
}

class LiveFollowedChannelsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChannelListBloc bloc = BlocProvider.of<ChannelListBloc>(context);
    bloc.add(LoadMyLiveFollowedChannels());

    return RefreshIndicator(child:
        BlocBuilder<ChannelListBloc, ChannelListState>(
            builder: (BuildContext context, ChannelListState state) {
      if (state is ChannelListLoading) {
        return Loading(context.t("Loading..."));
      }

      if (state is ChannelListNotLoaded) {
        return Text(context.t("Error loading channels"));
      }

      if (state is ChannelListLoaded) {
        final List<Channel> channels = state.results;

        if (channels.length == 0) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/glimrip.png'),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(context.t("None of the streams you follow are live.")),
                  ],
                ),
              ),
              height: MediaQuery.of(context).size.height,
            ),
          );
        }
        return ChannelList(channels: channels);
      }

      return Text("Unexpected");
    }), onRefresh: () async {
      bloc.add(LoadMyLiveFollowedChannels());
    });
  }
}
