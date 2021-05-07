import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/models.dart';

class Chat extends StatelessWidget {
  final Channel channel;
  final ChatMessagesBloc bloc;

  const Chat({required this.bloc, required this.channel}) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(channel.chatBackgroundUrl),
          repeat: ImageRepeat.repeat,
          alignment: Alignment.topLeft,
        ),
      ),
      child: _buildChatMessages(context),
    );
  }

  Widget _buildChatMessages(BuildContext context) {
    return BlocBuilder<ChatMessagesBloc, ChatMessagesState>(
        bloc: bloc,
        builder: (BuildContext context, ChatMessagesState state) {
          if (state is ChatMessagesLoading) {
            return Center(
              child: CircularProgressIndicator(
                semanticsLabel: "Loading ...",
              ),
            );
          }

          if (state is ChatMessagesNotLoaded) {
            return Text("Error loading channels");
          }

          if (state is ChatSubscriptionLoaded) {
            print("ChatSubscriptionLoaded in Chat.dart");
            final subscription = state.chatMessageSubscription;

            return StreamBuilder(
                stream: subscription,
                builder: (context, AsyncSnapshot<List<ChatMessage>> snapshot) {
                  print("StreamBuilder is updated");

                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return Center(
                      child: Text("Error"),
                    );
                  }

                  if (snapshot.hasData) {
                    final messages = snapshot.data!;

                    return ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      reverse: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildChatMessage(messages[index]);
                      },
                    );
                  }

                  return Text("Loading");
                });
          }

          return Text("Unexpected");
        });
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
                text: message.username + ": " + message.message,
                style: TextStyle(fontSize: 16),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
