import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/auth.dart';

class ChannelListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Category category = ModalRoute.of(context)!.settings.arguments as Category;
    final authState = AuthState.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("${category.name} Streams")),
      body: BlocProvider(
        create: (context) => ChannelListBloc(
          glimeshRepository: GlimeshRepository(client: authState!.client!),
        ),
        child: ChannelListWidget(categorySlug: category.slug),
      ),
    );
  }
}

class ChannelListWidget extends StatelessWidget {
  final String categorySlug;

  ChannelListWidget({required this.categorySlug});

  @override
  Widget build(BuildContext context) {
    ChannelListBloc bloc = BlocProvider.of<ChannelListBloc>(context);
    bloc.add(LoadChannels(categorySlug: this.categorySlug));

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
                      child: _buildCard(context, channels[index]),
                    ),
                  ),
                );
              }

              return Text("Unexpected");
            }),
        onRefresh: () async {
          bloc.add(LoadChannels(categorySlug: this.categorySlug));
        });
  }

  Widget _buildCard(BuildContext context, Channel channel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 220.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                // In order to have the ink splash appear above the image, you
                // must use Ink.image. This allows the image to be painted as part
                // of the Material and display ink effects above it. Using a
                // standard Image will obscure the ink splash.
                child: Ink.image(
                  image: NetworkImage(channel.thumbnail),
                  fit: BoxFit.cover,
                  child: Container(),
                ),
              ),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.black54,
                    ),
                    padding: EdgeInsets.all(15),
                    child: Text(channel.title),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
