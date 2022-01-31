import 'package:flutter/material.dart';
import 'package:glimesh_app/components/StreamTitle.dart';
import 'package:glimesh_app/components/SmallChip.dart';
import 'package:glimesh_app/models.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({
    required this.channel,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Stack(
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
        Positioned(
          top: 16.0,
          right: 16.0,
          left: 16.0,
          child: _buildTagArea(channel.tags, channel.subcategory),
        )
      ],
    );
  }

  Widget _buildTagArea(List<Tag> tags, Subcategory? subcategory) {
    return Wrap(
      textDirection: TextDirection.rtl,
      spacing: 2.0,
      runSpacing: 2.0,
      children: [
        if (subcategory != null)
          SmallChip(
            backgroundColor: Colors.cyanAccent.shade700,
            label:
                Text(subcategory.name, style: TextStyle(color: Colors.black)),
          ),
        ..._buildTags(tags),
      ],
    );
  }

  // Opting to limit to displaying the first 5 tags only here because on smaller
  // screens, we still want the user to be able to see the thumbnail
  List<Widget> _buildTags(List<Tag> tags) {
    return tags
        .take(4)
        .map(
          (Tag tag) =>
              SmallChip(label: Text(tag.name), backgroundColor: Colors.blue),
        )
        .toList();
  }
}
