import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/glimesh_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';

class ChannelScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Channel channel = ModalRoute.of(context)!.settings.arguments as Channel;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: FTLPlayer(channel: channel),
        ),
        Expanded(child: Chat()),
        ChatInput(),
      ],
    );
  }
}
