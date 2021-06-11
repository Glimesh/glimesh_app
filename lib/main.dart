import 'package:flutter/material.dart';
import 'package:glimesh_app/blocs/repos/chat_messages_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/glimesh.dart';
import 'package:glimesh_app/screens/CategoryListScreen.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:glimesh_app/screens/FollowingScreen.dart';
import 'package:glimesh_app/screens/ProfileScreen.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:glimesh_app/models.dart';
import 'package:glimesh_app/repository.dart';

Future<void> main() async {
  runApp(GlimeshApp());
}

class GlimeshApp extends StatelessWidget {
  Future<GraphQLClient> _client() async {
    const CLIENT_ID =
        String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');
    const CLIENT_SECRET = String.fromEnvironment('GLIMESH_CLIENT_SECRET',
        defaultValue: 'FAKE_VALUE');

    final oauthClient = await createOauthClient(CLIENT_ID, CLIENT_SECRET);
    final token = oauthClient.credentials.accessToken;

    final _socketUrl =
        'wss://glimesh.dev/api/graph/websocket?vsn=2.0.0&token=$token';
    final channel = PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: await channel);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );
  }

  @override
  Widget build(BuildContext context) {
    final whiteTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        );

    return FutureBuilder(
        future: _client(),
        builder: (BuildContext context, AsyncSnapshot<GraphQLClient> snapshot) {
          if (snapshot.hasData) {
            GraphQLClient client = snapshot.data!;

            final routes = <String, WidgetBuilder>{
              '/channels': (BuildContext context) =>
                  new ChannelListScreen(client: client),
              '/profile': (BuildContext context) =>
                  new ProfileScreen(client: client),
            };

            final generateRoutes = (settings) {
              if (settings.name == '/channel') {
                final Channel channel = settings.arguments as Channel;

                return MaterialPageRoute(
                  builder: (context) {
                    return BlocProvider(
                      create: (context) => ChatMessagesBloc(
                        glimeshRepository: GlimeshRepository(client: client),
                      ),
                      child: ChannelScreen(channel: channel),
                    );
                  },
                );
              }

              // Fail if we're missing any routes.
              assert(false, 'Need to implement ${settings.name}');
              return null;
            };

            return MaterialApp(
              title: 'Glimesh Alpha',
              routes: routes,
              onGenerateRoute: generateRoutes,
              theme: ThemeData(
                brightness: Brightness.dark,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Color(0xff060818),
                canvasColor: Color(0xff060818),
                bottomAppBarColor: Color(0xff0e1726),
                textTheme: whiteTextTheme,
              ),
              themeMode: ThemeMode.dark,
              home: MyHomePage(title: 'Glimesh Alpha', client: client),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Container(
                child: Text(
              "Error Loading API",
              textDirection: TextDirection.ltr,
            ));
          }

          return Container(
              child: Center(
            child: Text("Loading", textDirection: TextDirection.ltr),
          ));
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.client, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;
  final GraphQLClient client;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      pages = [
        ProfileScreen(client: widget.client),
        CategoryListScreen(),
        FollowingScreen(client: widget.client),
      ];
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        // leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => {}),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_active),
              onPressed: () => {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: pages.isEmpty ? Text("Loading") : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Following",
          ),
        ],
      ),
    );
  }

  _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // if (index == 0) {
    //   Navigator.pushNamed(context, '/profile');
    // }
  }
}
