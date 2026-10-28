import 'package:codo/screens/friends/friends_screen.dart';
import 'package:codo/screens/now/now_screen.dart';
import 'package:codo/screens/pacts/pacts_screen.dart';
import 'package:codo/screens/profile/profile_screen.dart';
import 'package:codo/screens/today/today_screen.dart';
import 'package:codo/widgets/home_background.dart';
import 'package:flutter/material.dart';
import 'package:codo/widgets/codo_nav_bar.dart';

// Carcasa de la app: barra inferior y las 5 secciones.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          fit: StackFit.expand,
          children: [
          const HomeBackground(),
        IndexedStack(
          index: _index,
          children: const [
            TodayScreen(),
            NowScreen(),
            PactsScreen(),
            FriendsScreen(),
            ProfileScreen(),
          ]),
          ]
      ),
          bottomNavigationBar: CodoNavBar(
          selectedIndex: _index, onSelected: (i) => setState(() => _index = i)),
    );
  }
}