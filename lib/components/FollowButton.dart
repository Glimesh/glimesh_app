import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/blocs/repos/follow_bloc.dart';
import 'package:glimesh_app/models.dart';

class FollowButton extends StatelessWidget {
  Channel channel;

  FollowButton({required this.channel});

  @override
  Widget build(BuildContext context) {
    FollowBloc bloc = BlocProvider.of<FollowBloc>(context);
    AuthState? authState = AuthState.of(context);

    return BlocBuilder<FollowBloc, FollowState>(
      builder: (BuildContext context, FollowState state) {
        print("Builder got $state");

        if (state is ChannelFollowed) {
          return _unfollowButton(
            () => bloc.add(UnfollowChannel(streamerId: channel.user_id)),
          );
        }
        if (state is ChannelNotFollowed) {
          return _followButton(
            () => bloc.add(FollowChannel(
                streamerId: channel.user_id, liveNotifications: false)),
          );
        }

        // state == FollowLoading || state == FollowNotLoaded
        return Padding(padding: EdgeInsets.zero);
      },
    );
  }

  _followButton(onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text("Follow"),
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.all(5),
      ),
    );
  }

  _unfollowButton(onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text("Unfollow"),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.all(5),
      ),
    );
  }
}
