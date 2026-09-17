import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class _NotificationItem {
  const _NotificationItem(this.title, this.body, this.icon);
  final String title;
  final String body;
  final IconData icon;
}

const _items = [
  _NotificationItem('حجزەکەت پشتڕاست کرا', 'حجزی تۆ سەرکەوتوو تۆمار کرا.', Icons.check_circle_outline),
  _NotificationItem('شوێنی نوێ زیادکرا', 'شوێنێکی نوێ لە ناوچەکەت زیاد کراوە.', Icons.place_outlined),
  _NotificationItem('ئاگاداری کەشوهەوا', 'باران/بەفر لە ناوچەی چیاکاندا چاوەڕوانکراوە.', Icons.cloudy_snowing),
  _NotificationItem('پێشنیاری تایبەت', 'داشکاندنی وەرزی بۆ چەند هۆتێلێک بەردەستە.', Icons.local_offer_outlined),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ئاگادارکردنەوەکان')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final n = _items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ListTile(
              leading: Icon(n.icon, color: AppColors.clay),
              title: Text(n.title),
              subtitle: Text(n.body),
            ),
          );
        },
      ),
    );
  }
}
