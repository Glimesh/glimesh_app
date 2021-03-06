import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSubmit;

  ChatInput({required this.onSubmit});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final messageController = TextEditingController();
  late FocusNode focusNode;

  void sendAndClear() {
    if (messageController.text == "") {
      return;
    }

    widget.onSubmit(messageController.text);

    messageController.text = "";
    focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
        height: 60,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: messageController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: context.t("Send a message"),
                  border: InputBorder.none,
                ),
                onSubmitted: (msg) => sendAndClear(),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              onPressed: () => sendAndClear(),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 18,
              ),
              backgroundColor: Colors.blue,
              elevation: 0,
            ),
          ],
        ),
      ),
    );
  }
}
