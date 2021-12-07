import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/components/ChannelCard.dart';

class CategoryListScreen extends StatelessWidget {
  final GraphQLClient client;

  const CategoryListScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChannelListBloc(
        glimeshRepository: GlimeshRepository(client: client),
      ),
      child: CategoryListWidget(),
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      _buildHeader(context),
      _buildButtons(context),
      _buildExploreHeader(context),
      _buildSomeStreams(context)
    ]);
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
                  "Next-Gen Live Streaming!",
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
                    "The first live streaming platform built around truly real time interactivity. Our streams are warp speed, our chat is blazing, and our community is thriving.",
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
                  "Explore Live Streams",
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
                    "Experience real time interaction by visiting some of these selected streams!",
                    style: Theme.of(context).textTheme.subtitle1),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                      name: "Gaming",
                      slug: "gaming",
                      icon: Icons.sports_esports)),
              buildButton(
                  context,
                  Category(
                    name: "Art",
                    slug: "art",
                    icon: Icons.color_lens,
                  )),
            ],
          ),
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                    name: "Music",
                    slug: "music",
                    icon: Icons.music_note,
                  )),
              buildButton(
                  context,
                  Category(
                    name: "Tech",
                    slug: "tech",
                    icon: Icons.memory,
                  )),
            ],
          ),
          Row(
            children: [
              buildButton(
                  context,
                  Category(
                    name: "IRL",
                    slug: "irl",
                    icon: Icons.photo_camera,
                  )),
              buildButton(
                  context,
                  Category(
                    name: "Education",
                    slug: "education",
                    icon: Icons.school,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, Category category) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
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
              Text(category.name)
            ],
          ),
          style: ElevatedButton.styleFrom(
            side: BorderSide(width: 1, color: Colors.grey),
            textStyle: Theme.of(context).textTheme.headline6,
            primary: Colors.transparent,
            padding: EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  Widget _buildSomeStreams(BuildContext context) {
    ChannelListBloc bloc = BlocProvider.of<ChannelListBloc>(context);
    bloc.add(LoadHomepageChannels());

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
                      child: Text("No live channels on the homepage"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: channels.length,
                  itemBuilder: (BuildContext context, int index) => InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/channel',
                        arguments: channels[index],
                      );
                    },
                    splashColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.12),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: new ChannelCard(channel: channels[index]),
                    ),
                  ),
                );
              }

              return Text("unexpected");
            }),
        onRefresh: () async {
          bloc.add(LoadHomepageChannels());
        });
  }
}
