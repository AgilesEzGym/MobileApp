import 'package:ezgym/screens/favorites.dart';
import 'package:ezgym/screens/home.dart';
import 'package:ezgym/screens/profile.dart';
import 'package:ezgym/screens/search.dart';
import 'package:flutter/material.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index){
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const<Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: 'home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'search'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'favorites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'profile')
        ],
      ),
      body: <Widget>[
        Home(),
        Search(),
        Favourites(),
        Profile()
      ][currentPageIndex],
    );
  }
}
