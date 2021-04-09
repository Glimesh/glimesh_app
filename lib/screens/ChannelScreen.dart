import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';

class ChannelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: FTLPlayer(),
        ),
        Expanded(child: Chat()),
        ChatInput(),
      ],
    );
  }
}
