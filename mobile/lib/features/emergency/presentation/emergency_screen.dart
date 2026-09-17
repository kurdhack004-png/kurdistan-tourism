import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Numbers carried over as-is from the project's own earlier emergency
/// page — Iraq/KRG police, ambulance and civil defense lines. Verify
/// these are current for your governorate before shipping.
const _contacts = [
  ('پۆلیس', '104'),
  ('یارمەتی پزیشکی', '122'),
  ('بەرگری کیવیل', '115'),
];

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('یارمەتی کتوپڕ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              children: [
                const Icon(Icons.emergency_outlined, color: AppColors.danger, size: 48),
                const SizedBox(height: AppSpacing.sm),
                Text('یارمەتی کتوپڕ', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'پەیوەندی بە خزمەتگوزاری فەرمی بکە و شوێنی خۆت هاوبەش بکە کاتێک پێویستە.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final c in _contacts)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(c.$1),
                subtitle: Text(c.$2),
                trailing: IconButton(
                  icon: const Icon(Icons.call_outlined, color: AppColors.danger),
                  onPressed: () => launchUrl(Uri.parse('tel:${c.$2}')),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => _shareLocation(context),
            icon: const Icon(Icons.my_location_rounded, size: 18),
            label: const Text('شوێنی خۆم بنێرە'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLocation(BuildContext context) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ڕێگەپێدانی شوێن پێویستە بۆ ئەم تایبەتمەندییە')));
      }
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}'));
  }
}
