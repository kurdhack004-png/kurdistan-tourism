import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/locations/models/tourist_location.dart';

/// Deliberately not Drift/SQLite here: a JSON blob in shared_preferences
/// needs no code generation step (no build_runner), which keeps this
/// project a plain `flutter pub get && flutter run` with no extra
/// commands. Locations are a small, read-mostly dataset per district, so
/// this scales fine for the offline_packages use case; if the cached set
/// grows into the tens of thousands of rows, swap this for Drift/Isar
/// (that adds one extra `dart run build_runner build` step).
class LocationCache {
  static const _key = 'cached_locations_v1';

  Future<void> save(List<TouristLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(locations.map(_toMap).toList());
    await prefs.setString(_key, raw);
  }

  Future<List<TouristLocation>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => _fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      // Corrupted/old-schema cache entry — treat as empty instead of
      // crashing the caller, which falls back to demo data.
      return [];
    }
  }

  // Includes rating/imageUrl now — a previous version of this cache
  // dropped both on save, so a location that had a real rating/photo
  // from the API would silently lose them after an app restart (falls
  // back to null, which is still handled safely everywhere it's read,
  // but shouldn't happen).
  Map<String, dynamic> _toMap(TouristLocation l) => {
        'id': l.id,
        'category': l.category,
        'name_ckb': l.nameCkb,
        'latitude': l.latitude,
        'longitude': l.longitude,
        'elevation_meters': l.elevationMeters,
        'description_ckb': l.descriptionCkb,
        'rating': l.rating,
        'image_url': l.imageUrl,
      };

  // Reads defensively: every field falls back to a safe default instead
  // of throwing if a value is missing or the wrong type, so a stale or
  // partially-written cache entry (e.g. from an older app version) can
  // never crash the list — it just renders with whatever it has.
  TouristLocation _fromMap(Map<String, dynamic> m) => TouristLocation(
        id: (m['id'] ?? '').toString(),
        category: (m['category'] ?? 'other').toString(),
        nameCkb: (m['name_ckb'] ?? 'شوێنی گەشتیاری').toString(),
        latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
        elevationMeters: (m['elevation_meters'] as num?)?.toInt(),
        descriptionCkb: m['description_ckb']?.toString(),
        rating: (m['rating'] as num?)?.toDouble(),
        imageUrl: m['image_url']?.toString(),
      );
}
