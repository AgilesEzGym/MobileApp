import 'package:ezgym/screens/favorites.dart';
import 'package:ezgym/screens/home.dart';
import 'package:ezgym/screens/login.dart';
import 'package:ezgym/screens/create.dart';
import 'package:ezgym/screens/profileScreen.dart';
import 'package:ezgym/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  final storage = FlutterSecureStorage();
  String? id; // Ya no es late
  int currentPageIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setParams();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
      body: <Widget>[
        Home(),
        Search(),
        Favourites(),
        Profile(id: id!) // id estará inicializado aquí
      ][currentPageIndex],
    );
  }

  void setParams() async {
    var uid = await storage.read(key: 'id');
    setState(() {
      id = uid;
      isLoading = false;
    });
    print("User ID: $id");
  }
}
