import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final screens = const [
      HomeScreen(),
      LocationsMapScreen(),
      FavoritesScreen(),
      TripPlannerScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.saffron.withValues(alpha: dark ? 0.22 : 0.25),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: 'map'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: 'favorites'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route),
            label: 'trip'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}
