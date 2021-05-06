import 'package:flutter/material.dart';
import 'package:glimesh_app/models.dart';

class StreamTitle extends StatefulWidget {
  final Channel channel;

  const StreamTitle({required this.channel}) : super();

  @override
  _StreamTitleState createState() => _StreamTitleState();
}

class _StreamTitleState extends State<StreamTitle> {
  bool _showMetadata = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        setState(() {
          _showMetadata = true;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(widget.channel.avatarUrl),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: _streamerContainer(),
                  ),
                ),
                _buttonContainer(),
              ],
            ),
          ),
          _showMetadata
              ? _metadataContainer()
              : Padding(padding: EdgeInsets.all(0)),
        ],
      ),
    );
  }

  Widget _metadataContainer() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragEnd: (details) {
        setState(() {
          _showMetadata = false;
        });
      },
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetadataItem("Game", "World of Warcraft"),
              _buildMetadataItem("Tags", "PC Gaming"),
              _buildMetadataItem("Language", "English"),
              _buildMetadataItem("Content", "Mature"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ElevatedButton(onPressed: () => {}, child: Text(content))
      ],
    );
  }

  Widget _streamerContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.channel.username,
            style: Theme.of(context).textTheme.subtitle1),
        Text(widget.channel.title),
      ],
    );
  }

  Widget _buttonContainer() {
    return Column(
      // layoutBehavior: ButtonBarLayoutBehavior.constrained,
      // crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        Padding(padding: EdgeInsets.only(bottom: 5)),
        ElevatedButton(
          onPressed: _toggleMetadata,
          child: Text("Follow"),
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(5),
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 5)),
        ElevatedButton(
          onPressed: () => {},
          child: Text("Subscribe"),
          style: ElevatedButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.all(5),
            primary: Colors.purple[700],
          ),
        ),
        Padding(padding: EdgeInsets.only(bottom: 5)),
      ],
    );
  }

  void _toggleMetadata() {
    setState(() {
      _showMetadata = !_showMetadata;
    });
  }
}
