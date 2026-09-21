import '../../core/network/api_client.dart';
import '../../features/locations/models/tourist_location.dart';
import '../local/location_cache.dart';

class LocationRepository {
  LocationRepository(this._api, this._cache);

  final ApiClient _api;
  final LocationCache _cache;

  Future<List<TouristLocation>> nearby({
    required double lat,
    required double lng,
    double radiusMeters = 350000,
  }) async {
    try {
      final res = await _api.client.get('/locations', queryParameters: {
        'near_lat': lat,
        'near_lng': lng,
        'radius_m': radiusMeters,
      });
      final raw = res.data is Map ? res.data['data'] : null;
      final list = raw is Map ? raw['data'] : raw;
      if (list is! List) throw const FormatException('Invalid locations response');
      final items = list
          .whereType<Map>()
          .map((e) => TouristLocation.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      await _cache.save(items);
      return items;
    } catch (_) {
      final cached = await _cache.load();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
