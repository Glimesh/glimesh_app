import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/channel_list_bloc.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:glimesh_app/components/Chat.dart';
import 'package:glimesh_app/components/ChatInput.dart';
import 'package:glimesh_app/components/FTLPlayer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../repository.dart';

class ChannelScreen extends StatelessWidget {
  final GraphQLClient client;

  const ChannelScreen({required this.client}) : super();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatMessagesBloc(
        glimeshRepository: GlimeshRepository(client: client),
      ),
      child: ChannelWidget(),
    );
  }
}

// Chat messages appear multiple times because this is a stateless widget and multiple LoadChatMessage events are sent
class ChannelWidget extends StatelessWidget {
  final Channel channel = Channel(
      id: 2,
      title: "Hello world",
      thumbnail:
          "https://glimesh-user-assets.nyc3.cdn.digitaloceanspaces.com/uploads/stream-thumbnails/79650.jpg?v=63786235374");

  Widget build(BuildContext context) {
    print("Built");
    BlocProvider.of<ChatMessagesBloc>(context)
        .add(LoadChatMessages(channelId: channel.id));

    return Scaffold(
        appBar: AppBar(title: Text(channel.title)),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Text("Video Player"),
              // child: FTLPlayer(channel: channel),
            ),
            Expanded(
                child: Chat(bloc: BlocProvider.of<ChatMessagesBloc>(context))),
            ChatInput(),
          ],
        ));
  }
}
//
// class ChannelScreen extends StatefulWidget {
//   @override
//   _ChannelState createState() => _ChannelState();
// }
//
// class _ChannelState extends State<ChannelScreen> {
//   Channel? channel;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     print("DID CHANGE DEPS");
//     // channel = ModalRoute.of(context)!.settings.arguments as Channel;
//
//     channel = Channel(
//         id: 2,
//         title: "Hello world",
//         thumbnail:
//             "https://glimesh-user-assets.nyc3.cdn.digitaloceanspaces.com/uploads/stream-thumbnails/79650.jpg?v=63786235374");
//
//     BlocProvider.of<ChatMessagesBloc>(context)
//         .add(LoadChatMessages(channelId: channel!.id));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         AspectRatio(aspectRatio: 16 / 9, child: Text("Video Player")
//             // child: FTLPlayer(channel: channel!),
//             ),
//         Expanded(child: Chat(bloc: BlocProvider.of<ChatMessagesBloc>(context))),
//         ChatInput(),
//       ],
//     );
//   }
// }
