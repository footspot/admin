import 'package:flutter/material.dart';
import 'package:fs_sa/presentation/features/home/add_club/add_club_view.dart';
import 'package:fs_sa/presentation/features/home/clubs/clubs_view.dart';
import 'package:fs_sa/presentation/features/home/home_controller.dart';
import 'package:fs_sa/presentation/features/home/intersport/intersport_view.dart';
import 'package:fs_sa/presentation/features/home/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 1;

  final views = {
    0: SettingsView(),
    1: ClubsView(),
    2: AddClubView(),
    3: IntersportView(),
  };

  @override
  void initState() {
    homeCtrler.stream.listen((index) => setState(() => _currentIndex = index));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: views[_currentIndex]!),
      bottomNavigationBar: BottomNavigationBar(
        // * Force fixed layout: 5+ items would otherwise default to shifting.
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Clubs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_outlined),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            label: 'Partnership',
          ),
        ],
      ),
    );
  }
}
