import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../locations/presentation/home_screen.dart';
import '../locations/presentation/locations_map_screen.dart';
import '../locations/presentation/favorites_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../trip/presentation/trip_planner_screen.dart';
import '../accommodations/presentation/nearby_stays_screen.dart';
import '../bookings/presentation/booking_history_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    const screens = [
      HomeScreen(),
      LocationsMapScreen(),
      FavoritesScreen(),
      TripPlannerScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.ink),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.terrain_rounded, color: AppColors.saffron, size: 42),
                    const Spacer(),
                    Text(
                      'app_name'.tr(),
                      style: const TextStyle(
                        color: AppColors.limestoneWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: Text('home'.tr()),
                onTap: () => _openPage(context, const HomeScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.explore_outlined),
                title: Text('explore'.tr()),
                onTap: () => _openPage(context, const HomeScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text('map'.tr()),
                onTap: () => _openPage(context, const LocationsMapScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.hotel_outlined),
                title: Text('hotels'.tr()),
                onTap: () => _openPage(
                  context,
                  const NearbyStaysScreen(lat: 36.1911, lng: 44.0092),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: Text('favorites'.tr()),
                onTap: () => _openPage(context, const FavoritesScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text('my_bookings'.tr()),
                onTap: () => _openPage(context, const BookingHistoryScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.route_outlined),
                title: Text('trip_plan'.tr()),
                onTap: () => _openPage(context, const TripPlannerScreen()),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('profile'.tr()),
                onTap: () => _openPage(context, const ProfileScreen()),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.saffron.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.25,
        ),
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
