import 'package:flutter/material.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/components/SmallChip.dart';

class StreamTitle extends StatefulWidget {
  final Channel channel;
  final bool? allowMetadata;

  const StreamTitle({required this.channel, this.allowMetadata}) : super();

  @override
  _StreamTitleState createState() => _StreamTitleState();
}

class _StreamTitleState extends State<StreamTitle> {
  bool _showMetadata = false;

  @override
  Widget build(BuildContext context) {
    if (widget.allowMetadata == true) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragEnd: (details) {
          setState(() {
            _showMetadata = true;
          });
        },
        child: _child(),
      );
    } else {
      return _child();
    }
  }

  Widget _child() {
    return Column(
      children: [
        Row(
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
        _showMetadata
            ? _metadataContainer()
            : Padding(padding: EdgeInsets.all(0)),
      ],
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
              _buildSubcategoryTag(),
              _buildTags(),
              _buildLanguageTag(),
              _buildMatureTag()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryTag() {
    if (widget.channel.subcategory == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Subcategory"),
        Chip(label: Text(widget.channel.subcategory!.name))
      ],
    );
  }

  Widget _buildTags() {
    List<Widget> tagButtons = widget.channel.tags
        .map((Tag tag) => Chip(label: Text(tag.name)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text("Tags"), Wrap(children: tagButtons)],
    );
  }

  Widget _buildLanguageTag() {
    if (widget.channel.language == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text("Language"), Chip(label: Text(widget.channel.language!))],
    );
  }

  Widget _buildMatureTag() {
    if (widget.channel.matureContent == false) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text("Content"), Chip(label: Text("Mature"))],
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
        Row(children: [
          Text(widget.channel.username,
              style: Theme.of(context).textTheme.subtitle1),
          if (widget.channel.language != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SmallChip(
                label: Text(widget.channel.language!,
                    style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.cyanAccent.shade700,
              ),
            ),
          if (widget.channel.matureContent)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: SmallChip(
                label: Text("Mature", style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.yellow.shade800,
              ),
            ),
        ]),
        Text(
          widget.channel.title,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buttonContainer() {
    return Padding(padding: EdgeInsets.zero);

    return Column(
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
        // ElevatedButton(
        //   onPressed: () => {},
        //   child: Text("Subscribe"),
        //   style: ElevatedButton.styleFrom(
        //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //     padding: EdgeInsets.all(5),
        //     primary: Colors.purple[700],
        //   ),
        // ),
        // Padding(padding: EdgeInsets.only(bottom: 5)),
      ],
    );
  }

  void _toggleMetadata() {
    setState(() {
      _showMetadata = !_showMetadata;
    });
  }
}
