import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/location_cache.dart';
import '../../../data/repositories/location_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/tourist_location.dart';

final locationCacheProvider = Provider<LocationCache>((ref) => LocationCache());

final locationRepositoryProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(
    ref.watch(apiClientProvider),
    ref.watch(locationCacheProvider),
  ),
);

/// Params for the nearby-locations query.
class NearbyParams {
  const NearbyParams(this.lat, this.lng);
  final double lat;
  final double lng;
}

final nearbyLocationsProvider =
    FutureProvider.family<List<TouristLocation>, NearbyParams>((ref, params) {
  return ref.watch(locationRepositoryProvider).nearby(lat: params.lat, lng: params.lng);
});
