import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:glimesh_app/blocs/repos/follow_bloc.dart';
import 'package:glimesh_app/models.dart';

class FollowButton extends StatelessWidget {
  Channel channel;

  FollowButton({required this.channel});

  @override
  Widget build(BuildContext context) {
    FollowBloc bloc = BlocProvider.of<FollowBloc>(context);
    return BlocBuilder<FollowBloc, FollowState>(
      builder: (BuildContext context, FollowState state) {
        print("Builder got $state");

        if (state is ChannelFollowed) {
          return _unfollowButton(
            context,
            () => bloc.add(UnfollowChannel(streamerId: channel.user_id)),
          );
        }
        if (state is ChannelNotFollowed) {
          return _followButton(
            context,
            () => bloc.add(FollowChannel(
                streamerId: channel.user_id, liveNotifications: false)),
          );
        }

        // state == FollowLoading || state == FollowNotLoaded
        return Padding(padding: EdgeInsets.zero);
      },
    );
  }

  _followButton(BuildContext context, onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(context.t("Follow")),
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.all(5),
      ),
    );
  }

  _unfollowButton(BuildContext context, onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(context.t("Unfollow")),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueGrey,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.all(5),
      ),
    );
  }
}
