import 'package:flutter/material.dart';
import 'package:glimesh_app/screens/CategoryListScreen.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:gql_phoenix_link/gql_phoenix_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> main() async {
  runApp(GlimeshApp());
}

class GlimeshApp extends StatelessWidget {
  Future<GraphQLClient> _client() async {
    const CLIENT_ID =
        String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');

    final _socketUrl =
        'wss://glimesh.tv/api/socket/websocket?vsn=2.0.0&client_id=$CLIENT_ID';
    final channel = PhoenixLink.createChannel(websocketUri: _socketUrl);
    final PhoenixLink _phoenixLink = PhoenixLink(channel: await channel);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _phoenixLink,
    );
  }

  waitForClient(connected) {
    _client().then((value) => connected(value));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _client(),
        builder: (BuildContext context, AsyncSnapshot<GraphQLClient> snapshot) {
          if (snapshot.hasData) {
            GraphQLClient client = snapshot.data!;

            final routes = <String, WidgetBuilder>{
              '/channels': (BuildContext context) =>
                  new ChannelListScreen(client: client),
              '/channel': (BuildContext context) =>
                  new ChannelScreen(client: client),
            };

            return MaterialApp(
              title: 'Glimesh Alpha',
              routes: routes,
              theme: ThemeData(
                brightness: Brightness.dark,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: Color(0xff060818),
                canvasColor: Color(0xff060818),
                bottomAppBarColor: Color(0xff0e1726),
                textTheme: TextTheme().apply(
                    bodyColor: Color(0xffffffff),
                    displayColor: Color(0xffffffff)),
              ),
              themeMode: ThemeMode.dark,
              home: MyHomePage(title: 'Glimesh Alpha'),
            );
          } else if (snapshot.hasError) {
            return Container(child: Text("Error Loading API"));
          }

          return Container(
              child: Center(
            child: Text("Loading", textDirection: TextDirection.ltr),
          ));
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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
      body: CategoryListScreen(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Following",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
