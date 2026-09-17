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

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(_fromMap).toList();
  }

  Map<String, dynamic> _toMap(TouristLocation l) => {
        'id': l.id,
        'category': l.category,
        'name_ckb': l.nameCkb,
        'latitude': l.latitude,
        'longitude': l.longitude,
        'elevation_meters': l.elevationMeters,
        'description_ckb': l.descriptionCkb,
      };

  TouristLocation _fromMap(Map<String, dynamic> m) => TouristLocation(
        id: m['id'] as String,
        category: m['category'] as String,
        nameCkb: m['name_ckb'] as String,
        latitude: (m['latitude'] as num).toDouble(),
        longitude: (m['longitude'] as num).toDouble(),
        elevationMeters: m['elevation_meters'] as int?,
        descriptionCkb: m['description_ckb'] as String?,
      );
}
