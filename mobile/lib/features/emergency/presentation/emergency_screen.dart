import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../content/providers/content_provider.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Numbers are managed from the admin dashboard; the built-in list is
    // shown while loading and whenever the backend is unreachable.
    final contacts = ref.watch(emergencyProvider).value ?? kDefaultEmergencyContacts;

    return Scaffold(
      appBar: AppBar(title: Text('emergency'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
            child: Column(children: [
              const Icon(Icons.emergency_outlined, color: AppColors.danger, size: 48),
              const SizedBox(height: AppSpacing.sm),
              Text('emergency'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('share_location'.tr(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final c in contacts)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(c.label),
                subtitle: Text(c.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.call_outlined, color: AppColors.danger),
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: c.phone.replaceAll(' ', ''))),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(onPressed: () => _shareLocation(context), icon: const Icon(Icons.my_location_rounded, size: 18), label: Text('share_location'.tr())),
        ],
      ),
    );
  }

  Future<void> _shareLocation(BuildContext context) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('location_permission'.tr())));
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}'));
  }
}
