import 'package:flutter/material.dart';
import 'package:glimesh_app/components/Loading.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:glimesh_app/screens/ProfileScreen.dart';
import 'package:glimesh_app/screens/CategoryListScreen.dart';
import 'package:glimesh_app/screens/FollowingScreen.dart';
import 'package:glimesh_app/auth.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  int _selectedIndex = 0;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      pages = [
        MyProfileScreen(),
        CategoryListScreen(),
        FollowingScreen(),
      ];
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = AuthState.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black.withOpacity(0.7),
        // leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => {}),
        actions: [
          // IconButton(
          //     icon: const Icon(Icons.notifications_active),
          //     onPressed: () => {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      return Text(
                        'Glimesh (${snapshot.data!.version}+${snapshot.data!.buildNumber})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      );
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
            _anonymousUserInfo(authState!.anonymous),
            if (authState.authenticated == false)
              ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            if (authState.authenticated == true)
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: authState.logout,
              ),
          ],
        ),
      ),
      body: pages.isEmpty ? Loading("Loading") : pages[_selectedIndex],
      bottomNavigationBar: _bottomNavigationBar(authState.authenticated),
    );
  }

  Widget _anonymousUserInfo(bool shown) {
    if (shown) {
      return ListTile(
        title: Text("Login to experience the very best Glimesh has to offer!"),
      );
    } else {
      return SizedBox();
    }
  }

  Widget? _bottomNavigationBar(bool shown) {
    if (shown) {
      return BottomNavigationBar(
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
      );
    }
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
