import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/models.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({
    required this.channel,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.black54,
              ),
              padding: EdgeInsets.all(0),
              child: StreamTitle(channel: channel, allowMetadata: false),
            ),
          ),
        ],
      ),
    );
  }
}
