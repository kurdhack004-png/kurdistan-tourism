import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/accommodation.dart';

class NearbyAccommodationsParams {
  const NearbyAccommodationsParams(this.lat, this.lng);
  final double lat;
  final double lng;
}

/// Public accommodation data comes from the backend.
/// We intentionally do not fall back to fabricated/demo businesses or prices.
final nearbyAccommodationsProvider =
    FutureProvider.family<List<Accommodation>, NearbyAccommodationsParams>((ref, params) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.client.get('/accommodations', queryParameters: {
    'near_lat': params.lat,
    'near_lng': params.lng,
  });
  final raw = res.data is Map ? res.data['data'] : null;
  final list = raw is Map ? raw['data'] : raw;
  if (list is! List) {
    throw const FormatException('Invalid accommodations response');
  }
  return list
      .whereType<Map>()
      .map((e) => Accommodation.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});
