import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class ChatMessage {
  String messageContent;
  String username;
  ChatMessage({required this.messageContent, required this.username});
}

class _ChatState extends State<Chat> {
  List<ChatMessage> messages = [
    ChatMessage(
      messageContent: "Hello world",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "This is a clever demo",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "Of a chat that looks real",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "but is not...",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "yet!",
      username: "clone1018",
    ),ChatMessage(
      messageContent: "Hello world",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "This is a clever demo",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "Of a chat that looks real",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "but is not...",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "yet!",
      username: "clone1018",
    ),ChatMessage(
      messageContent: "Hello world",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "This is a clever demo",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "Of a chat that looks real",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "but is not...",
      username: "clone1018",
    ),
    ChatMessage(
      messageContent: "yet!",
      username: "clone1018",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
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
                    messages[index].messageContent,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        );
      },
    );
  }
}
