import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/reviews_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key, required this.reviewableType, required this.reviewableId, required this.title});

  final String reviewableType;
  final String reviewableId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (reviewableType, reviewableId);
    final reviews = ref.watch(reviewsProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text('review_title'.tr(namedArgs: {'title': title}))),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.saffron,
        foregroundColor: AppColors.inkDeep,
        icon: const Icon(Icons.rate_review_outlined),
        label: Text('review_write'.tr()),
        onPressed: () => _openWriteReviewSheet(context, ref, key),
      ),
      body: reviews.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text('review_empty'.tr(), style: const TextStyle(color: AppColors.riverstone)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final r = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Row(
                    children: [
                      Text(r.userName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 8),
                      ...List.generate(5, (s) => Icon(
                            s < r.rating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 14, color: AppColors.saffronDeep)),
                    ],
                  ),
                  subtitle: r.comment != null ? Text(r.comment!) : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        error: (e, st) => Center(
          child: Text('reviews_load_failed'.tr(), style: Theme.of(context).textTheme.bodyMedium)),
      ),
    );
  }

  void _openWriteReviewSheet(BuildContext context, WidgetRef ref, (String, String) key) {
    if (!ref.read(authProvider).isAuthenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    int rating = 5;
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.lg,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('review_yours'.tr(), style: Theme.of(sheetContext).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: List.generate(5, (i) => IconButton(
                  onPressed: () => setSheetState(() => rating = i + 1),
                  icon: Icon(
                    i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.saffronDeep, size: 28),
                )),
              ),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: InputDecoration(hintText: 'review_comment_hint'.tr()),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ref.read(reviewsProvider(key).notifier).submit(
                          rating: rating, comment: commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim());
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                  child: Text('send'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
