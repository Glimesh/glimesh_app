import 'package:flutter/material.dart';
import 'package:glimesh_app/components/ChannelCard.dart';
import 'package:glimesh_app/models.dart';

class ChannelList extends StatelessWidget {
  final List<Channel> channels;

  const ChannelList({
    required this.channels,
  }) : super();

  @override
  Widget build(BuildContext context) {
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
        splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        // Generally, material cards do not have a highlight overlay.
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
          child: ChannelCard(channel: channels[index]),
        ),
      ),
    );
  }
}
