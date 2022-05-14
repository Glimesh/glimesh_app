import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/models.dart';

class Chat extends StatelessWidget {
  final Channel channel;

  const Chat({required this.channel});

  @override
  Widget build(BuildContext context) {
    ChatMessagesBloc bloc = BlocProvider.of<ChatMessagesBloc>(context);
    AuthState? authState = AuthState.of(context);

    return Column(
      children: [
        // Chat Messages Box
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(channel.chatBackgroundUrl),
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topLeft,
              ),
            ),
            child: ChatMessages(),
          ),
        ),
        // Chat Input
        _buildChatInput(
          context,
          authState!.anonymous,
          (message) => bloc.add(SendChatMessage(
            channelId: channel.id,
            message: message,
          )),
        )
      ],
    );
  }

  _buildChatInput(BuildContext context, anonymous, onSubmit) {
    if (anonymous) {
      return Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: context.t("Please login to chat!"),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: Text(context.t("Login")),
            ),
          ],
        ),
      );
    }

    return ChatInput(onSubmit: onSubmit);
  }
}

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Rebuilding Chat Messages");

    return BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
      builder: (context, state) {
        print("Got new state $state");
        if (state is ChatMessagesLoaded) {
          return ListView.builder(
            itemCount: state.messages.length,
            shrinkWrap: true,
            reverse: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildChatMessage(context, state.messages[index]);
            },
          );
        }

        return Loading("");
      },
    );
  }

  Widget _buildChatMessage(BuildContext context, ChatMessage message) {
    return Container(
      padding: EdgeInsets.all(2),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border:
                message.isSystemMessage ? Border.all(color: Colors.cyan) : null,
            color: Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF0E1826).withOpacity(0.90)
                : Colors.white.withOpacity(0.90),
          ),
          padding: EdgeInsets.all(10),
          child: Text.rich(
            TextSpan(children: [
              ..._buildUserBadges(message.metadata),
              _buildAvatar(message),
              TextSpan(
                text: message.username + (message.isSystemMessage ? "" : ": "),
                style: TextStyle(
                    fontSize: 16, color: _getNameColour(message.metadata)),
              ),
              ..._buildTokens(message.tokens)
            ]),
          ),
        ),
      ),
    );
  }

  final double smallEmoteSize = 20;
  final double bigEmoteSize = 64;

  List<InlineSpan> _buildTokens(List<MessageToken> tokens) {
    return tokens.map((token) {
      if (token.tokenType == "emote" && token.src != null) {
        // on the web, if an message is just an emote, we make it bigger, let's do that here too!
        var emoteSize = tokens.length == 1 ? bigEmoteSize : smallEmoteSize;

        return WidgetSpan(
            child: Padding(
                child: SizedBox(child: _drawEmote(token), width: emoteSize),
                padding: EdgeInsets.symmetric(horizontal: 4)));
      }

      // we don't know the token type, or it's just text, just return the text for now.
      return TextSpan(
        text: token.text,
        style: TextStyle(fontSize: 16),
      );
    }).toList();
  }

  // due to restrictions with flutter's selection of SVG libraries, we're having to use png
  // emotes, which, given we never show them above text size 64, shouldn't *really* be an issue
  Widget _drawEmote(MessageToken token) {
    var url = token.src!;

    if (token.src!.contains(".svg")) {
      url = token.src!.replaceAll(".svg", ".png");
    }

    return Image(
      image: CachedNetworkImageProvider(url),
      filterQuality: FilterQuality.medium,
    );
  }

  List<InlineSpan> _buildUserBadges(MessageMetadata? meta) {
    if (meta == null) return List.empty();

    var badges = <InlineSpan>[];

    if (meta.admin) badges.add(_badge(Icons.verified_user, Colors.red));
    if (meta.moderator)
      badges.add(_badge(Icons.security, Colors.blue.shade700));
    if (meta.streamer) badges.add(_badge(Icons.tv, Colors.blue));
    if (meta.subscriber)
      badges.add(_badge(Icons.emoji_events, Colors.purple.shade800));

    return badges;
  }

  WidgetSpan _badge(IconData icon, Color color) {
    return WidgetSpan(
        child: Padding(
      child: DecoratedBox(
        child: Padding(
            child: Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(2)),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      ),
      padding: EdgeInsets.only(right: 4),
    ));
  }

  Color? _getNameColour(MessageMetadata? meta) {
    if (meta == null) return null;
    if (meta.platformFounderSubscriber) return Colors.yellow.shade700;

    return null;
  }

  WidgetSpan _buildAvatar(ChatMessage message) {
    if (message.metadata != null) {
      if (message.metadata!.platformFounderSubscriber ||
          message.metadata!.platformSupporterSubscriber) {
        return WidgetSpan(
          child: Padding(
            padding: EdgeInsets.only(right: 5),
            child: DecoratedBox(
              child: Padding(
                  child: CircleAvatar(
                    radius: 9,
                    backgroundImage: NetworkImage(message.avatarUrl),
                  ),
                  padding: EdgeInsets.all(1)),
              decoration: ShapeDecoration(
                  shape: CircleBorder(
                      side:
                          BorderSide(color: Colors.yellow.shade700, width: 1))),
            ),
          ),
        );
      }
    }

    return WidgetSpan(
      child: Padding(
        padding: EdgeInsets.only(right: 5),
        child: CircleAvatar(
          radius: 10,
          backgroundImage: NetworkImage(message.avatarUrl),
        ),
      ),
    );
  }
}
