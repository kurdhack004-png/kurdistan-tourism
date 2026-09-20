import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/local/demo_data.dart';
import '../../locations/models/tourist_location.dart';
import '../../locations/providers/locations_provider.dart';
import '../providers/trip_provider.dart';

class TripPlannerScreen extends ConsumerWidget {
  const TripPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripIds = ref.watch(tripProvider);
    return Scaffold(
      appBar: AppBar(title: Text('trip_plan'.tr())),
      body: FutureBuilder<List<TouristLocation>>(
        future: ref.read(locationCacheProvider).load(),
        builder: (context, snapshot) {
          final all = snapshot.data == null || snapshot.data!.isEmpty ? demoLocations : snapshot.data!;
          final trip = all.where((l) => tripIds.contains(l.id)).toList();
          if (trip.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Text('trip_empty'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.riverstone))));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: trip.length,
            itemBuilder: (context, i) {
              final loc = trip[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.saffron.withValues(alpha: 0.25), child: Text('${i + 1}', style: const TextStyle(color: AppColors.saffronDeep))),
                  title: Text(loc.nameCkb),
                  subtitle: Text(loc.category),
                  trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.riverstone), onPressed: () => ref.read(tripProvider.notifier).toggle(loc.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
