import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../content/providers/content_provider.dart';

class _NotificationItem {
  const _NotificationItem(this.title, this.body, this.icon);
  final String title;
  final String body;
  final IconData icon;
}

/// Shown only when the backend cannot be reached (offline / demo mode).
const _offlineItems = [
  _NotificationItem('حجزەکەت پشتڕاست کرا', 'حجزی تۆ سەرکەوتوو تۆمار کرا.', Icons.check_circle_outline),
  _NotificationItem('شوێنی نوێ زیادکرا', 'شوێنێکی نوێ لە ناوچەکەت زیاد کراوە.', Icons.place_outlined),
  _NotificationItem('ئاگاداری کەشوهەوا', 'باران/بەفر لە ناوچەی چیاکاندا چاوەڕوانکراوە.', Icons.cloudy_snowing),
  _NotificationItem('پێشنیاری تایبەت', 'داشکاندنی وەرزی بۆ چەند هۆتێلێک بەردەستە.', Icons.local_offer_outlined),
];

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remote = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('notifications'.tr())),
      body: remote.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        // The provider never throws (it returns null when offline), but keep
        // the placeholders as the safe fallback anyway.
        error: (e, st) => _list(context, _offlineItems),
        data: (items) {
          if (items == null) return _list(context, _offlineItems);
          if (items.isEmpty) {
            return Center(
              child: Text('no_notifications'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            );
          }
          return _list(
            context,
            items.map((n) => _NotificationItem(n.title, n.body, Icons.notifications_outlined)).toList(),
          );
        },
      ),
    );
  }

  Widget _list(BuildContext context, List<_NotificationItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final n = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Icon(n.icon, color: AppColors.clay),
            title: Text(n.title),
            subtitle: n.body.isEmpty ? null : Text(n.body),
          ),
        );
      },
    );
  }
}
