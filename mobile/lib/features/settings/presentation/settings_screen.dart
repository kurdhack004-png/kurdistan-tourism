import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionCard(
            children: [
              SwitchListTile(
                value: settings.darkMode,
                onChanged: notifier.setDarkMode,
                title: Text('dark_mode'.tr()),
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
              SwitchListTile(
                value: settings.notificationsEnabled,
                onChanged: notifier.setNotifications,
                title: Text('notifications'.tr()),
                secondary: const Icon(Icons.notifications_outlined),
              ),
              SwitchListTile(
                value: settings.locationEnabled,
                onChanged: notifier.setLocation,
                title: Text('location_gps'.tr()),
                secondary: const Icon(Icons.location_on_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text('language'.tr()),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(value: 'ckb', child: Text('kurdish'.tr())),
                    DropdownMenuItem(value: 'ar', child: Text('arabic'.tr())),
                    DropdownMenuItem(value: 'en', child: Text('english'.tr())),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      notifier.setLanguage(v);
                      context.setLocale(Locale(v));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            children: [
              ListTile(title: Text('terms'.tr())),
              ListTile(title: Text('privacy'.tr())),
              ListTile(title: Text('about'.tr())),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
