import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/glimesh_bloc.dart';

class ChannelListScreen extends StatefulWidget {
  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelListScreen> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<ChannelListBloc>(context).add(LoadChannels());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListChannels(
            bloc: BlocProvider.of<ChannelListBloc>(context),
          )
        ],
      ),
    );
  }
}

class ListChannels extends StatelessWidget {
  final ChannelListBloc bloc;

  const ListChannels({required this.bloc}) : super();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChannelListBloc, ChannelListState>(
        bloc: bloc,
        builder: (BuildContext context, ChannelListState state) {
          print(state);
          if (state is ChannelListLoading) {
            return Expanded(
              child: Container(
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: "Loading ...",
                  ),
                ),
              ),
            );
          }

          if (state is ChannelListNotLoaded) {
            return Text("Error loading channels");
          }

          if (state is ChannelListLoaded) {
            final List<Channel> channels = state.results;

            return Expanded(
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (BuildContext context, int index) =>
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/channel',
                          arguments: channels[index],
                        );
                      },
                      // Generally, material cards use onSurface with 12% opacity for the pressed state.
                      splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                      // Generally, material cards do not have a highlight overlay.
                      highlightColor: Colors.transparent,
                      child: _buildCard(context, channels[index]),
                    )
              ),
            );
          }

          return Text("Unexpected");
        });
  }

  Widget _buildCard(BuildContext context, Channel channel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Photo and title.
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
                    child:  Text(channel.title),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, Channel channel) {
    return InkWell(
      onTap: () => {
        print("clicked")
        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => PropertyScreen(rental: rental)))
      },
      child: ListTile(
        title: Text(channel.title),
        leading: Image.network(
          channel.thumbnail,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    this.title,
  }) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title!, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}
