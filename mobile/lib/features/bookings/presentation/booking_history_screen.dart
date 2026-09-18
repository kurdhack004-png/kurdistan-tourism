import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حجزەکانم')),
      body: bookings.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('هێشتا هیچ حجزێکت نییە.', style: TextStyle(color: AppColors.riverstone)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(bookingProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final b = items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    title: Text(b.accommodationName),
                    subtitle: Text('${_fmt(b.checkIn)} → ${_fmt(b.checkOut)} • ${b.guests} میوان'),
                    trailing: _StatusChip(status: b.status),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (e, st) => Center(
          child: Text('نەتوانرا حجزەکان بار بکرێن', style: Theme.of(context).textTheme.bodyMedium)),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final labels = {
      'pending': 'چاوەڕوان',
      'confirmed': 'پ��تڕاستکراوە',
      'cancelled': 'هەڵوەشێنراوە',
      'completed': 'تەواوبووە',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.saffron.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(labels[status] ?? status,
          style: const TextStyle(fontSize: 11, color: AppColors.saffronDeep, fontWeight: FontWeight.w600)),
    );
  }
}
