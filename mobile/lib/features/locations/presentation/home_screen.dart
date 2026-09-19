import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/mountain_ridge_divider.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../providers/locations_provider.dart';
import 'widgets/category_tab_bar.dart';
import 'widgets/location_card.dart';
import 'location_detail_screen.dart';

const _categories = ['هەموو', 'کێوەکان', 'دەریاچە', 'ئەشکەوت', 'دابەزین'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = _categories.first;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Erbil as the default center — the repository already falls back to
    // cached/offline data when there's no connection.
    final nearby = ref.watch(nearbyLocationsProvider(const NearbyParams(36.1911, 44.0092)));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero(count: nearby.value?.length)),
          SliverToBoxAdapter(
            child: MountainRidgeDivider(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryTabBar(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (c) => setState(() => _selectedCategory = c),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SearchField(onChanged: (value) => setState(() => _query = value.trim())),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          nearby.when(
            data: (items) {
              final filtered = items.where((loc) {
                final q = _query.toLowerCase();
                final matchesSearch = q.isEmpty || loc.nameCkb.toLowerCase().contains(q) || loc.descriptionCkb.toString().toLowerCase().contains(q);
                if (_selectedCategory == 'هەموو') return matchesSearch;
                final category = _selectedCategory == 'کێوەکان' ? 'mountain' : _selectedCategory == 'دەریاچە' ? 'lake' : _selectedCategory == 'ئەشکەوت' ? 'cave' : 'waterfall';
                final matchesCategory = loc.category == category;
                return matchesSearch && matchesCategory;
              }).toList();
              return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final loc = filtered[i];
                  return LocationCard(
                    location: loc,
                    rating: loc.rating,
                    imageUrl: loc.imageUrl,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LocationDetailScreen(location: loc)),
                    ),
                  );
                },
              ),
            );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator(color: AppColors.saffron)),
              ),
            ),
            error: (e, st) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text('ئینتەرنێت نییە — داتای پاشەکەوتکراو پیشان دەدرێت',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.count});
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(color: AppColors.ink),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('گەشتیاری کوردستان',
                  style: TextStyle(color: AppColors.limestoneWhite, fontSize: 14, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emergency_outlined, color: AppColors.limestoneWhite, size: 20),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.limestoneWhite, size: 20),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('شاخەکانی هەولێر',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: AppColors.limestoneWhite, fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                count == null ? 'بارکردنی شوێنەکان...' : '$count شوێنی گەشتیاری بەردەستە',
                style: const TextStyle(color: Color(0xFFC9C2AA), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'گەڕان بۆ شوێن یان چیاکان...',
        hintStyle: const TextStyle(color: AppColors.riverstone, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.riverstone, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
      ),
    );
  }
}
