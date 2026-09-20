import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/register_screen.dart';
import '../../bookings/presentation/booking_history_screen.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../trip/presentation/trip_planner_screen.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('profile_title'.tr())),
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
            label: 'trip_plan'.tr(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TripPlannerScreen())),
          ),
          _ProfileTile(
            icon: Icons.calendar_today_outlined,
            label: 'my_bookings'.tr(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BookingHistoryScreen())),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            label: 'notifications'.tr(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          _ProfileTile(
            icon: Icons.emergency_outlined,
            label: 'emergency'.tr(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen())),
          ),
          _ProfileTile(
            icon: Icons.download_outlined,
            label: 'offline_package'.tr(),
            onTap: () {}, // wire to GET /api/offline-packages once that endpoint exists
          ),
          _ProfileTile(
            icon: Icons.settings_outlined,
            label: 'settings'.tr(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (ref.watch(authProvider).isAuthenticated && ref.watch(authProvider).role == 'admin')
            _ProfileTile(icon: Icons.admin_panel_settings_outlined, label: 'admin_panel'.tr(), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen()))),
          if (!ref.watch(authProvider).isAuthenticated) ...[
            _ProfileTile(
              icon: Icons.login_rounded,
              label: 'login'.tr(),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
            _ProfileTile(
              icon: Icons.person_add_alt_1_rounded,
              label: 'register'.tr(),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
          ] else
            _ProfileTile(
              icon: Icons.logout_rounded,
              label: 'logout'.tr(),
              danger: true,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (!context.mounted) return;
                // authProvider state change rebuilds this ConsumerWidget.
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
