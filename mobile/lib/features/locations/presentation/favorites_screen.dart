import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/local/favorites_provider.dart';
import '../providers/locations_provider.dart';
import 'location_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(favoritesProvider);
    final locations = ref.watch(nearbyLocationsProvider(const NearbyParams(36.1911, 44.0092)));
    return Scaffold(
      appBar: AppBar(title: const Text('دڵخوازەکان')),
      body: locations.when(
        data: (items) {
          final saved = items.where((l) => ids.contains(l.id)).toList();
          if (saved.isEmpty) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('هێشتا هیچ شوێنێکت دڵخواز نەکردووە.'),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: saved.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final l = saved[i];
              return Card(child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.landscape_outlined)),
                title: Text(l.nameCkb),
                subtitle: Text(l.descriptionCkb ?? l.category, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(l.id),
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LocationDetailScreen(location: l))),
              ));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('نەتوانرا دڵخوازەکان باربکرێن.')),
      ),
    );
  }
}
