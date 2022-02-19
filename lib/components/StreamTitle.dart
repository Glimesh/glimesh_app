import 'package:flutter/material.dart';
import 'package:glimesh_app/components/FollowButton.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/components/SmallChip.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

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
    Widget streamerContainer = Padding(
      padding: EdgeInsets.all(5),
      child: _streamerContainer(),
    );

    Widget inkwellOrPlain = widget.allowMetadata == true
        ? InkWell(
            child: streamerContainer,
            onTap: _toggleMetadata,
          )
        : streamerContainer;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(3),
              child: InkWell(
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(widget.channel.avatarUrl),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, "/profile",
                        arguments: widget.channel.username);
                  }),
            ),
            Expanded(
              child: inkwellOrPlain,
            ),
            if (widget.allowMetadata == true) _buttonContainer(),
          ],
        ),
        AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstChild: Container(height: 0, width: double.infinity),
            secondChild: _metadataContainer(context),
            crossFadeState: _showMetadata
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst)
      ],
    );
  }

  Widget _metadataContainer(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildSubcategoryTag(),
            _buildTags(context),
            _buildLanguageTag(context),
            _buildMatureTag()
          ],
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

  Widget _buildTags(BuildContext context) {
    List<Widget> tagButtons = widget.channel.tags
        .map((Tag tag) => Chip(label: Text(tag.name)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(context.t("Tags")), Wrap(children: tagButtons)],
    );
  }

  Widget _buildLanguageTag(BuildContext context) {
    if (widget.channel.language == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t("Language")),
        Chip(label: Text(widget.channel.language!))
      ],
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
    // return Padding(padding: EdgeInsets.zero);

    return Column(
      children: [
        Padding(padding: EdgeInsets.only(bottom: 5)),
        Padding(
          padding: EdgeInsets.only(right: 5),
          child: FollowButton(channel: widget.channel),
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
