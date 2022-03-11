import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/components/ChannelList.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:glimesh_app/track.dart';

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    return BlocProvider(
      create: (context) => ChannelListBloc(
        glimeshRepository: GlimeshRepository(client: authState!.client!),
      ),
      child: CategoryListWidget(),
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChannelListBloc bloc = BlocProvider.of<ChannelListBloc>(context);
    bloc.add(LoadHomepageChannels());

    return RefreshIndicator(
      child: ListView(
        children: [
          _buildHeader(context),
          _buildButtons(context),
          _buildExploreHeader(context),
          _buildSomeStreams(bloc)
        ],
      ),
      onRefresh: () async => bloc.add(LoadHomepageChannels()),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  "${context.t("Next-Gen")} ${context.t("Live Streaming!")}",
                  style: Theme.of(context).textTheme.headline4,
                  // style: TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                    context.t(
                        "The first live streaming platform built around truly real time interactivity. Our streams are warp speed, our chat is blazing, and our community is thriving."),
                    style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  context.t("Explore Live Streams"),
                  style: Theme.of(context).textTheme.headline4,
                  // style: TextStyle(fontSize: 20),
                  maxLines: 1,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                    context.t(
                        "Experience real time interaction by visiting some of these selected streams!"),
                    style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Category> categories = [
    Category(name: "Gaming", slug: "gaming", icon: Icons.sports_esports),
    Category(name: "Art", slug: "art", icon: Icons.color_lens),
    Category(name: "Music", slug: "music", icon: Icons.music_note),
    Category(name: "Tech", slug: "tech", icon: Icons.memory),
    Category(name: "IRL", slug: "irl", icon: Icons.photo_camera),
    Category(name: "Education", slug: "education", icon: Icons.school)
  ];

  Widget _buildButtons(BuildContext context) {
    bool horizontalTablet = MediaQuery.of(context).size.width > 992;

    List<Widget> buttons = [];
    categories.forEach((category) {
      buttons.add(buildButton(context, category));
    });

    List<Widget> children = horizontalTablet
        ? [
            Row(
              children: buttons,
            )
          ]
        : _splitIntoRows(buttons, 2);

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: children,
      ),
    );
  }

  List<Widget> _splitIntoRows(children, int chunkSize) {
    List<Widget> chunks = [];
    for (var i = 0; i < children.length; i += chunkSize) {
      chunks.add(Row(
        children: children.sublist(i,
            i + chunkSize > children.length ? children.length : i + chunkSize),
      ));
    }
    return chunks;
  }

  Widget buildButton(BuildContext context, Category category) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: OutlinedButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/channels',
            arguments: category,
          ),
          child: Column(
            children: [
              Icon(
                category.icon,
                color: Colors.blue,
                size: 50,
              ),
              Text(context.t(category.name))
            ],
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(width: 1, color: Colors.grey),
            textStyle: Theme.of(context).textTheme.headline6,
            primary: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            padding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSomeStreams(ChannelListBloc bloc) {
    return BlocBuilder<ChannelListBloc, ChannelListState>(
        builder: (BuildContext context, ChannelListState state) {
      if (state is ChannelListLoading) {
        return Container(child: Loading(context.t("Loading Streams")));
      }

      if (state is ChannelListNotLoaded) {
        return Container(child: Text(context.t("Error loading channels")));
      }

      if (state is ChannelListLoaded) {
        final List<Channel> channels = state.results;

        if (channels.length == 0) {
          return Center(
              child: Text(context.t("No live channels on the homepage")));
        }

        return ChannelList(channels: channels);
      }

      return Text("unexpected");
    });
  }
}
