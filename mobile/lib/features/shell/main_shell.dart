import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../locations/presentation/home_screen.dart';
import '../locations/presentation/locations_map_screen.dart';
import '../locations/presentation/favorites_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../trip/presentation/trip_planner_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    LocationsMapScreen(),
    FavoritesScreen(),
    TripPlannerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.saffron.withOpacity(dark ? 0.22 : 0.25),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'سەرەتا'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'نەخشە'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'دڵخواز'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'گەشت'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'هەژمار'),
        ],
      ),
    );
  }
}
