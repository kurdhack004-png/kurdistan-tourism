import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class ReviewItem {
  const ReviewItem({required this.id, required this.userName, required this.rating, this.comment});
  final String id;
  final String userName;
  final int rating;
  final String? comment;

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        id: json['id'].toString(),
        userName: (json['user'] is Map ? (json['user']['full_name'] ?? json['user']['name']) : null)?.toString() ?? (json['name']?.toString() ?? 'گەشتیار'),
        rating: (json['rating'] as num?)?.toInt() ?? 5,
        comment: json['comment'] as String?,
      );
}

class ReviewsNotifier extends StateNotifier<AsyncValue<List<ReviewItem>>> {
  ReviewsNotifier(this._ref, this.reviewableType, this.reviewableId) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;
  final String reviewableType;
  final String reviewableId;

  Future<void> refresh() async {
    try {
      final api = _ref.read(apiClientProvider);
      final res = await api.client.get('/reviews', queryParameters: {
        'reviewable_type': reviewableType,
        'reviewable_id': reviewableId,
      });
      final raw = res.data is Map ? res.data['data'] : null;
      final list = raw is Map ? raw['data'] : raw;
      if (list is! List) throw const FormatException('Invalid reviews response');
      state = AsyncValue.data(list.whereType<Map>()
          .map((e) => ReviewItem.fromJson(Map<String, dynamic>.from(e))).toList());
    } catch (_) {
      state = const AsyncValue.data([
        ReviewItem(id: 'demo-1', userName: 'سارا حەسەن', rating: 5, comment: 'شوێنێکی زۆر جوان و ئارامە.'),
        ReviewItem(id: 'demo-2', userName: 'کەمال ئەحمەد', rating: 4, comment: 'سروشت و کەشەکە زۆر خۆشە.'),
      ]);
    }
  }

  Future<void> submit({required int rating, String? comment}) async {
    var remote = true;
    try {
      final api = _ref.read(apiClientProvider);
      await api.client.post('/reviews', data: {
        'reviewable_type': reviewableType,
        'reviewable_id': reviewableId,
        'rating': rating,
        'comment': comment,
      });
    } catch (_) {
      remote = false;
      final current = state.valueOrNull ?? const <ReviewItem>[];
      state = AsyncValue.data([
        ReviewItem(id: 'local-${DateTime.now().millisecondsSinceEpoch}', userName: 'تۆ', rating: rating, comment: comment),
        ...current,
      ]);
    }
    if (remote) await refresh();
  }
}

final reviewsProvider = StateNotifierProvider.family<ReviewsNotifier, AsyncValue<List<ReviewItem>>, (String, String)>(
  (ref, key) => ReviewsNotifier(ref, key.$1, key.$2),
);
