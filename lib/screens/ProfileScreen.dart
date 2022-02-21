import 'package:flutter/material.dart';
import 'package:glimesh_app/auth.dart';
import 'package:glimesh_app/blocs/repos/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class UserProfileScreen extends StatelessWidget {
  final String username;

  const UserProfileScreen({required this.username}) : super();

  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of<UserBloc>(context);
    bloc.add(LoadUser(username: username));

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: BlocBuilder(
          bloc: bloc,
          builder: (BuildContext context, UserState state) {
            return ProfileWidget(userState: state, isMyProfile: false);
          }),
    );
  }
}

class MyProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    return Container(
      child: BlocProvider(
        create: (context) => UserBloc(
          glimeshRepository: GlimeshRepository(client: authState!.client!),
        ),
        child: _MyProfileWidget(),
      ),
    );
  }
}

// this is intentionally a bit hacky, but it works
class _MyProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserBloc bloc = BlocProvider.of<UserBloc>(context);
    bloc.add(LoadMyself());

    return BlocBuilder(
        bloc: bloc,
        builder: (BuildContext context, UserState state) {
          return ProfileWidget(userState: state, isMyProfile: true);
        });
  }
}

class ProfileWidget extends StatelessWidget {
  final UserState userState;
  final bool isMyProfile;

  const ProfileWidget({required this.userState, required this.isMyProfile})
      : super();

  @override
  Widget build(BuildContext context) {
    if (userState is UserLoading) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            semanticsLabel: "Loading ...",
          ),
        ),
      );
    }

    if (userState is UserNotLoaded) {
      return Text("Error loading user");
    }
    if (userState is UserLoaded) {
      User user = (userState as UserLoaded).user;

      if (MediaQuery.of(context).size.width > 992) {
        // render side-by-side
        return _buildSideBySide(context, user);
      } else {
        // render stacked
        return _buildStacked(context, user);
      }
    }

    return Text("Unexpected");
  }

  Widget _buildStacked(BuildContext context, User user) {
    return Column(children: [
      _buildProfileInfo(context, user),
      Padding(padding: EdgeInsets.only(bottom: 5)),
      Expanded(
          child: Markdown(
              data: user.profileContentMd ?? "",
              onTapLink: _handleMarkdownLinkTap))
    ]);
  }

  Widget _buildSideBySide(BuildContext context, User user) {
    return Container(
        padding: EdgeInsets.all(20),
        child: Row(children: [
          Expanded(flex: 3, child: _buildProfileInfo(context, user)),
          Expanded(
              flex: 9,
              child: Markdown(
                  data: user.profileContentMd ?? "",
                  onTapLink: _handleMarkdownLinkTap)),
        ]));
  }

  void _handleMarkdownLinkTap(String _text, String? href, String _title) {
    _openLink(href!);
  }

  Widget _buildProfileInfo(BuildContext context, User user) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 5)),
        Text(user.username, style: Theme.of(context).textTheme.headline5),
        _buildTeamRole(user),
        Padding(padding: EdgeInsets.only(bottom: 5)),
        CircleAvatar(radius: 64, backgroundImage: NetworkImage(user.avatarUrl)),
        //TODO pronouns (when we get them in the API)
        Container(child: _buildSocials(user)),
        Row(children: [
          Column(children: [
            Text("Followers"),
            Text(user.countFollowers.toString()),
          ]),
          _buildChannelOrProfileButton(),
          Column(children: [
            Text("Following"),
            Text(user.countFollowing.toString()),
          ]),
        ], mainAxisAlignment: MainAxisAlignment.spaceEvenly),
        //TODO report (pending API)
      ],
    );
  }

  Widget _buildChannelOrProfileButton() {
    if (isMyProfile)
      return Padding(
        padding: EdgeInsets.zero,
      );
    else {
      return ElevatedButton(
        onPressed: () {},
        child: Text("Follow"),
        style: ElevatedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.all(5),
        ),
      );
    }
  }

  Widget _buildTeamRole(User user) {
    if (user.teamRole == null) return Container(width: 0, height: 0);

    Color? colour;

    switch (user.teamRole) {
      case "Community Team":
        colour = Colors.green[600];
        break;
      case "Core Team":
        colour = Colors.red;
        break;
    }

    return Text(user.teamRole!, style: TextStyle(color: colour));
  }

  Widget _buildSocials(User user) {
    List<Widget> socials = [];

    if (user.socials.length > 0) {
      for (Social social in user.socials) {
        // just check for twitter for now
        if (social.platform == "twitter") {
          socials.add(IconButton(
              onPressed: () {
                _openLink("https://twitter.com/${social.username}");
              },
              icon: FaIcon(FontAwesomeIcons.twitter)));
        }
      }
    }

    if (user.socialYoutube != null) {
      socials.add(
        IconButton(
            onPressed: () {
              _openLink("https://youtube.com/${user.socialYoutube}");
            },
            icon: FaIcon(FontAwesomeIcons.youtube)),
      );
    }

    if (user.socialInstagram != null) {
      socials.add(
        IconButton(
            onPressed: () {
              _openLink("https://instagram.com/${user.socialInstagram}");
            },
            icon: FaIcon(FontAwesomeIcons.instagram)),
      );
    }

    if (user.socialDiscord != null) {
      socials.add(
        IconButton(
            onPressed: () {
              _openLink("https://discord.com/invite/${user.socialDiscord}");
            },
            icon: FaIcon(FontAwesomeIcons.discord)),
      );
    }

    if (user.socialGuilded != null) {
      socials.add(
        IconButton(
            onPressed: () {
              _openLink(user.socialGuilded!);
            },
            icon: FaIcon(FontAwesomeIcons.guilded)),
      );
    }

    return Row(children: socials, mainAxisAlignment: MainAxisAlignment.center);
  }

  void _openLink(String link) async {
    try {
      await launch(link);
    } catch (e) {
      throw (e);
    }
  }
}
