import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../bookings/presentation/booking_history_screen.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../trip/presentation/trip_planner_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('هەژماری من')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.clay,
            child: Icon(Icons.person_rounded, size: 36, color: AppColors.limestoneWhite),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileTile(
            icon: Icons.map_outlined,
            label: 'پلانی گەشتم',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TripPlannerScreen())),
          ),
          _ProfileTile(
            icon: Icons.calendar_today_outlined,
            label: 'حجزەکانم',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookingHistoryScreen())),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            label: 'ئاگادارکردنەوەکان',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          _ProfileTile(
            icon: Icons.emergency_outlined,
            label: 'یارمەتی کتوپڕ',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen())),
          ),
          _ProfileTile(
            icon: Icons.download_outlined,
            label: 'پاکێجی ئۆفلاین',
            onTap: () {}, // wire to GET /api/offline-packages once that endpoint exists
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            label: 'ڕێکخستنەکان',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ProfileTile(
            icon: Icons.logout_rounded,
            label: 'چوونەدەرەوە',
            danger: true,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap, this.danger = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.charcoal;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 14)),
      trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.riverstone, size: 18),
      onTap: onTap,
    );
  }
}
