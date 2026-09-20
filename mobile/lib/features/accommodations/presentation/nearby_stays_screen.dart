import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../bookings/presentation/booking_screen.dart';
import '../providers/accommodations_provider.dart';

class NearbyStaysScreen extends ConsumerWidget {
  const NearbyStaysScreen({super.key, required this.lat, required this.lng});

  final double lat;
  final double lng;

  Future<void> _startBooking(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required String name,
    required double price,
  }) async {
    if (!ref.read(authProvider).isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!context.mounted || !ref.read(authProvider).isAuthenticated) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          accommodationId: id,
          accommodationName: name,
          pricePerNight: price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stays = ref.watch(
      nearbyAccommodationsProvider(
        NearbyAccommodationsParams(lat, lng),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('nearby_stays'.tr())),
      body: stays.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'no_stays'.tr(),
                style: const TextStyle(color: AppColors.riverstone),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final a = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: const Icon(
                    Icons.villa_outlined,
                    color: AppColors.clay,
                  ),
                  title: Text(a.nameCkb),
                  subtitle: Text(
                    '${a.type} • ${a.pricePerNight.toStringAsFixed(0)} د.ع/شەو',
                  ),
                  trailing: FilledButton(
                    onPressed: () => _startBooking(
                      context,
                      ref,
                      id: a.id,
                      name: a.nameCkb,
                      price: a.pricePerNight,
                    ),
                    child: Text('book'.tr()),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.saffron),
        ),
        error: (e, st) => Center(
          child: Text(
            'نەتوانرا شوێنی مانەوە بار بکرێن',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
