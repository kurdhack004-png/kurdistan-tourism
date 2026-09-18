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
      appBar: AppBar(title: const Text('ڕێکخستنەکان')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionCard(
            children: [
              SwitchListTile(
                value: settings.darkMode,
                onChanged: notifier.setDarkMode,
                title: const Text('دۆخی تاریک'),
                secondary: const Icon(Icons.dark_mode_outlined),
              ),
              SwitchListTile(
                value: settings.notificationsEnabled,
                onChanged: notifier.setNotifications,
                title: const Text('ئاگادارکردنەوەکان'),
                secondary: const Icon(Icons.notifications_outlined),
              ),
              SwitchListTile(
                value: settings.locationEnabled,
                onChanged: notifier.setLocation,
                title: const Text('خزمەتگوزاری شوێن (GPS)'),
                secondary: const Icon(Icons.location_on_outlined),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionCard(
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('زمان'),
                trailing: DropdownButton<String>(
                  value: settings.language,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'ckb', child: Text('کوردی')),
                    DropdownMenuItem(value: 'ar', child: Text('عەربی')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
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
          const _SectionCard(
            children: [
              ListTile(title: Text('مەرج و ڕێساکان')),
              ListTile(title: Text('پارێزگاری تایبەتێتی')),
              ListTile(title: Text('دەربارەی گەشتیاری کوردستان')),
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
