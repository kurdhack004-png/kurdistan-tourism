import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/category_visual.dart';
import '../../../core/widgets/mountain_ridge_divider.dart';
import '../../../core/widgets/safe_build.dart';
import '../../content/providers/content_provider.dart';
import '../../emergency/presentation/emergency_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../providers/locations_provider.dart';
import 'widgets/category_tab_bar.dart';
import 'widgets/location_card.dart';
import 'location_detail_screen.dart';

const _categories = ['all', 'mountains', 'lakes', 'caves', 'waterfalls'];
const _heroSlides = [
  ('mountain', 'hero_mountains'),
  ('lake', 'hero_lakes'),
  ('waterfall', 'hero_waterfalls'),
  ('cave', 'hero_caves'),
  ('history', 'hero_history'),
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
    final languageCode = context.locale.languageCode;
    final nearby = ref.watch(nearbyLocationsProvider(const NearbyParams(36.1911, 44.0092)));

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Hero(count: nearby.value?.length)),
          SliverToBoxAdapter(child: MountainRidgeDivider(color: Theme.of(context).scaffoldBackgroundColor)),
          const SliverToBoxAdapter(child: _AdBanner()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: 'nearby_places'.tr(),
                    icon: Icons.explore_rounded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CategoryTabBar(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (c) => setState(() => _selectedCategory = c),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                    loc.localizedName(languageCode).toLowerCase().contains(q) ||
                    (loc.localizedDescription(languageCode)?.toLowerCase().contains(q) ?? false);
                if (_selectedCategory == 'all') return matchesSearch;
                final category = _selectedCategory == 'mountains'
                    ? 'mountain'
                    : _selectedCategory == 'lakes'
                        ? 'lake'
                        : _selectedCategory == 'caves'
                            ? 'cave'
                            : 'waterfall';
                return matchesSearch && loc.category == category;
              }).toList();

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _EmptyState(
                      icon: Icons.search_off_rounded,
                      text: 'data_load_failed'.tr(),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final loc = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SafeBuild(
                        label: 'location-card:${loc.id}',
                        builder: (_) => LocationCard(
                          location: loc,
                          rating: loc.rating,
                          imageUrl: loc.imageUrl,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => LocationDetailScreen(location: loc)),
                          ),
                        ),
                        fallback: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(loc.localizedName(languageCode), style: Theme.of(context).textTheme.bodyMedium),
                        ),
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
                child: _EmptyState(
                  icon: Icons.cloud_off_rounded,
                  text: 'no_connection_showing_cached'.tr(),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.saffron.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.saffron, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.riverstone),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Hero extends ConsumerStatefulWidget {
  const _Hero({this.count});
  final int? count;

  @override
  ConsumerState<_Hero> createState() => _HeroState();
}

class _HeroState extends ConsumerState<_Hero> {
  int _slideIndex = 0;
  int _slideCount = _heroSlides.length;
  int _intervalSec = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _intervalSec), (_) {
      if (!mounted || _slideCount < 2) return;
      setState(() => _slideIndex = (_slideIndex + 1) % _slideCount);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = ref.watch(heroProvider).value;
    final remoteImages = hero?.images ?? const <String>[];
    final useImages = remoteImages.length >= 5;
    final images = useImages ? remoteImages.take(5).toList(growable: false) : const <String>[];
    _slideCount = useImages ? images.length : _heroSlides.length;
    final wantedInterval = hero?.intervalSec ?? 5;
    if (wantedInterval != _intervalSec) {
      _intervalSec = wantedInterval;
      _startTimer();
    }
    final index = _slideIndex % _slideCount;
    final (category, label) = _heroSlides[index % _heroSlides.length];
    final (icon, tint) = categoryVisual(category);

    return Container(
      height: 270,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.ink),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: useImages
                ? SizedBox.expand(
                    key: ValueKey('hero-image-$index-${images[index]}'),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(color: AppColors.ink),
                      errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.ink),
                    ),
                  )
                : Container(
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
                      child: Icon(icon, size: 112, color: Colors.white.withValues(alpha: 0.16)),
                    ),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.ink.withValues(alpha: 0.20), AppColors.ink.withValues(alpha: 0.90)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 22, AppSpacing.lg, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: .12)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.public_rounded, color: AppColors.saffron, size: 15),
                        const SizedBox(width: 6),
                        Text('app_slogan'.tr(), style: const TextStyle(color: AppColors.limestoneWhite, fontSize: 11, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    Row(children: [
                      _HeroIconButton(icon: Icons.emergency_outlined, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmergencyScreen()))),
                      const SizedBox(width: 6),
                      _HeroIconButton(icon: Icons.notifications_outlined, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    ]),
                  ],
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!useImages) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(label.tr(), key: ValueKey(label), style: const TextStyle(color: AppColors.saffron, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Text('region_title'.tr(), style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.limestoneWhite, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(widget.count == null ? 'loading_places'.tr() : 'locations_available'.tr(namedArgs: {'count': widget.count.toString()}), style: const TextStyle(color: Color(0xFFD5CEB9), fontSize: 12)),
                ]),
                Row(children: List.generate(_slideCount, (i) {
                  final active = i == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 5),
                    width: active ? 20 : 5,
                    height: 5,
                    decoration: BoxDecoration(color: active ? AppColors.saffron : Colors.white.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(3)),
                  );
                })),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withValues(alpha: .22),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(padding: const EdgeInsets.all(9), child: Icon(icon, color: AppColors.limestoneWhite, size: 19)),
        ),
      );
}

class _AdBanner extends ConsumerWidget {
  const _AdBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsProvider).value ?? const <AdItem>[];
    if (ads.isEmpty) return const SizedBox.shrink();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = ads.length == 1 ? screenWidth - AppSpacing.lg * 2 : 280.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ads.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, i) => _AdCard(ad: ads[i], width: cardWidth),
        ),
      ),
    );
  }
}

class _AdCard extends StatelessWidget {
  const _AdCard({required this.ad, required this.width});
  final AdItem ad;
  final double width;

  Future<void> _open() async {
    final uri = Uri.tryParse(ad.link);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.cardRadius);
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: ad.link.isEmpty ? null : _open,
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ad.image.isNotEmpty)
                CachedNetworkImage(imageUrl: ad.image, fit: BoxFit.cover, placeholder: (_, __) => const ColoredBox(color: AppColors.clay), errorWidget: (_, __, ___) => const ColoredBox(color: AppColors.clay))
              else
                const ColoredBox(color: AppColors.clay),
              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.ink.withValues(alpha: 0.8)]))),
              PositionedDirectional(
                top: 8,
                end: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.saffron, borderRadius: BorderRadius.circular(6)),
                  child: Text('ad'.tr(), style: const TextStyle(fontSize: 10, color: AppColors.ink, fontWeight: FontWeight.w600)),
                ),
              ),
              PositionedDirectional(
                start: 10,
                end: 10,
                bottom: 8,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(ad.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.limestoneWhite, fontSize: 14, fontWeight: FontWeight.w700)),
                  if (ad.company.isNotEmpty) Text(ad.company, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.limestoneWhite, fontSize: 11)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
