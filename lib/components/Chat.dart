import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';

class Chat extends StatelessWidget {
  final ChatMessagesBloc bloc;

  const Chat({required this.bloc}) : super();

  @override
  Widget build(BuildContext context) {
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

            ScrollController _scrollController = ScrollController();

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
                    // if (messages.length > 0) {
                    //   _scrollController.animateTo(
                    //       _scrollController.position.maxScrollExtent,
                    //       curve: Curves.easeOut,
                    //       duration: const Duration(milliseconds: 500));
                    // }

                    return ListView.builder(
                      itemCount: messages.length,
                      shrinkWrap: true,
                      reverse: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(3),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                // 0e1826
                                color: Color(0xFF0E1826),
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text(
                                messages[index].username +
                                    ": " +
                                    messages[index].message,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Text("Loading");
                });
          }

          return Text("Unexpected");
        });
  }
}
