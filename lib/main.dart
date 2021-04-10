import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glimesh_app/blocs/repos/glimesh_bloc.dart';
import 'package:glimesh_app/repository.dart';
import 'package:glimesh_app/screens/ChannelListScreen.dart';
import 'package:glimesh_app/screens/ChannelScreen.dart';
import 'package:glimesh_app/screens/LoginScreen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<void> main() async {
  runApp(GlimeshApp());
}

class GlimeshApp extends StatelessWidget {
  GraphQLClient _client() {
    final HttpLink _httpLink = HttpLink(
      'https://glimesh.tv/api',
    );

    // This is to be replaced with actual authentication
    const CLIENT_ID = String.fromEnvironment('GLIMESH_CLIENT_ID', defaultValue: 'FAKE_VALUE');

    final AuthLink _authLink = AuthLink(
      getToken: () =>
          'Client-ID $CLIENT_ID',
    );

    final Link _link = _authLink.concat(_httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _link,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glimesh',
      routes: {
        '/channels': (_) => BlocProvider(
              create: (context) => ChannelListBloc(
                glimeshRepository: GlimeshRepository(client: _client()),
              ),
              child: Scaffold(body: ChannelListScreen()),
            ),
        '/channel': (_) => Scaffold(
              appBar: AppBar(
                title: Text("Channel Page"),
              ),
              body: ChannelScreen(),
            )
      },
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      home: MyHomePage(title: 'Glimesh'),
    );
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
      ),
      body: LoginScreen(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Channels",
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
