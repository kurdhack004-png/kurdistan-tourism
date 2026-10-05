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

  static const screens = <Widget>[
    HomeScreen(),
    LocationsMapScreen(),
    FavoritesScreen(),
    TripPlannerScreen(),
    ProfileScreen(),
  ];

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      drawer: _buildDrawer(context),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 70,
              backgroundColor: dark ? AppColors.inkDeep : AppColors.limestoneWhite,
              elevation: 16,
              indicatorColor: AppColors.saffron.withValues(alpha: dark ? .20 : .16),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? AppColors.saffron : theme.colorScheme.onSurfaceVariant,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: selected ? 25 : 23,
                  color: selected ? AppColors.saffron : theme.colorScheme.onSurfaceVariant,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: 'home'.tr()),
                NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map_rounded), label: 'map'.tr()),
                NavigationDestination(icon: const Icon(Icons.favorite_border_rounded), selectedIcon: const Icon(Icons.favorite_rounded), label: 'favorites'.tr()),
                NavigationDestination(icon: const Icon(Icons.route_outlined), selectedIcon: const Icon(Icons.route_rounded), label: 'trip'.tr()),
                NavigationDestination(icon: const Icon(Icons.person_outline_rounded), selectedIcon: const Icon(Icons.person_rounded), label: 'profile'.tr()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.sizeOf(context).width * .86,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.ink, AppColors.inkDeep]),
              ),
              child: Row(children: [
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(color: AppColors.saffron.withValues(alpha: .14), borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.saffron.withValues(alpha: .35))),
                  child: const Icon(Icons.terrain_rounded, color: AppColors.saffron, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('app_name'.tr(), style: const TextStyle(color: AppColors.limestoneWhite, fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('app_slogan'.tr(), style: TextStyle(color: AppColors.limestoneWhite.withValues(alpha: .65), fontSize: 11)),
                ])),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                children: [
                  _section('explore'.tr()),
                  _tile(context, Icons.home_rounded, 'home'.tr(), _index == 0, () { Navigator.pop(context); setState(() => _index = 0); }),
                  _tile(context, Icons.explore_rounded, 'explore'.tr(), false, () => _openPage(context, const HomeScreen())),
                  _tile(context, Icons.map_rounded, 'map'.tr(), _index == 1, () { Navigator.pop(context); setState(() => _index = 1); }),
                  _tile(context, Icons.hotel_rounded, 'hotels'.tr(), false, () => _openPage(context, const NearbyStaysScreen(lat: 36.1911, lng: 44.0092))),
                  const SizedBox(height: 10),
                  _section('trip_plan'.tr()),
                  _tile(context, Icons.favorite_rounded, 'favorites'.tr(), _index == 2, () { Navigator.pop(context); setState(() => _index = 2); }),
                  _tile(context, Icons.route_rounded, 'trip_plan'.tr(), _index == 3, () { Navigator.pop(context); setState(() => _index = 3); }),
                  _tile(context, Icons.calendar_month_rounded, 'my_bookings'.tr(), false, () => _openPage(context, const BookingHistoryScreen())),
                  const SizedBox(height: 10),
                  _section('profile'.tr()),
                  _tile(context, Icons.person_rounded, 'profile'.tr(), _index == 4, () { Navigator.pop(context); setState(() => _index = 4); }),
                  _tile(context, Icons.settings_rounded, 'settings'.tr(), false, () => _openPage(context, const ProfileScreen())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Text('Kurdistan Tourism • V12 PRO', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 7),
        child: Text(title.toUpperCase(), style: const TextStyle(color: AppColors.riverstone, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
      );

  Widget _tile(BuildContext context, IconData icon, String title, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          selected: selected,
          selectedTileColor: AppColors.saffron.withValues(alpha: .12),
          leading: Icon(icon, size: 21, color: selected ? AppColors.saffron : null),
          title: Text(title, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w800 : FontWeight.w500)),
          onTap: onTap,
        ),
      );
}
