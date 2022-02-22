import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  _buildChatInput(context, anonymous, onSubmit) {
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
                  hintText: "Please login to chat!",
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, "/login"),
              child: Text("Login"),
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
            padding: EdgeInsets.only(top: 10, bottom: 10),
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildChatMessage(state.messages[index]);
            },
          );
        }

        return Loading("");
      },
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      padding: EdgeInsets.all(3),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Color(0xFF0E1826),
          ),
          padding: EdgeInsets.all(10),
          child: Text.rich(
            TextSpan(children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(message.avatarUrl),
                  ),
                ),
              ),
              TextSpan(
                text: message.username + ": ",
                style: TextStyle(fontSize: 16),
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
}
