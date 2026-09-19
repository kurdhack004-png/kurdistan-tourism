import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/category_visual.dart';
import '../../../core/widgets/mountain_ridge_divider.dart';
import '../../../core/widgets/safe_build.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../providers/locations_provider.dart';
import 'widgets/category_tab_bar.dart';
import 'widgets/location_card.dart';
import 'location_detail_screen.dart';

const _categories = ['هەموو', 'کێوەکان', 'دەریاچە', 'ئەشکەوت', 'دابەزین'];

/// The 5 scenes the hero banner cycles through, one every 5 seconds.
/// These reuse the same category icon/gradient language as the rest of
/// the app (see `categoryVisual`) rather than stock photos, so the
/// rotation stays on-brand and needs no network access to render.
const _heroSlides = [
  ('mountain', 'چیاکانی کوردستان'),
  ('lake', 'دەریاچە سروشتییەکان'),
  ('waterfall', 'ئاودانە جوانەکان'),
  ('cave', 'ئەشکەوتە مێژووییەکان'),
  ('history', 'شوێنە کلتوورییەکان'),
];

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
                  SafeBuild(
                    label: 'search-field',
                    builder: (_) => _SearchField(onChanged: (value) => setState(() => _query = value.trim())),
                    fallback: const SizedBox(height: 48),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          nearby.when(
            data: (items) {
              final filtered = items.where((loc) {
                final q = _query.toLowerCase();
                final matchesSearch = q.isEmpty ||
                    loc.nameCkb.toLowerCase().contains(q) ||
                    (loc.descriptionCkb?.toLowerCase().contains(q) ?? false);
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
                  return SafeBuild(
                    label: 'location-card:${loc.id}',
                    builder: (_) => LocationCard(
                      location: loc,
                      rating: loc.rating,
                      imageUrl: loc.imageUrl,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LocationDetailScreen(location: loc)),
                      ),
                    ),
                    // If a single item's data is ever malformed, show its
                    // name only instead of taking down the whole list.
                    fallback: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(loc.nameCkb, style: Theme.of(context).textTheme.bodyMedium),
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

class _Hero extends StatefulWidget {
  const _Hero({this.count});
  final int? count;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _slideIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Cycle to the next of the 5 hero scenes every 5 seconds. The timer
    // is cancelled in dispose(), so it never fires after this widget
    // (and its BuildContext) is gone.
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _slideIndex = (_slideIndex + 1) % _heroSlides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (category, label) = _heroSlides[_slideIndex];
    final (icon, tint) = categoryVisual(category);

    return Container(
      height: 240,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.ink),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Rotating background: cross-fades between 5 scenes every 5s.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: Container(
              key: ValueKey(category),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tint.withValues(alpha: 0.9), AppColors.ink],
                ),
              ),
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.lg),
                child: Icon(icon, size: 96, color: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
          ),
          // Readability scrim over the image so text stays legible on
          // every one of the 5 tints.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.ink.withValues(alpha: 0.35), AppColors.ink.withValues(alpha: 0.85)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
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
                    // The rotating slide's own label fades in above the
                    // fixed screen title, so the banner clearly reads as
                    // "showcasing different things" rather than the
                    // title itself changing underneath the user.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        label,
                        key: ValueKey(label),
                        style: const TextStyle(color: AppColors.saffron, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('شاخەکانی هەولێر',
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: AppColors.limestoneWhite, fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      widget.count == null ? 'بارکردنی شوێنەکان...' : '${widget.count} شوێنی گەشتیاری بەردەستە',
                      style: const TextStyle(color: Color(0xFFC9C2AA), fontSize: 12),
                    ),
                  ],
                ),
                // Dot indicator so the rotation reads as an intentional
                // carousel, not a flicker.
                Row(
                  children: List.generate(_heroSlides.length, (i) {
                    final active = i == _slideIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(left: 5),
                      width: active ? 16 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: active ? AppColors.saffron : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
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
