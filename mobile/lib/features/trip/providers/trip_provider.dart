import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A user's self-planned route: an ordered list of location IDs they've
/// added from the detail screen. Persisted locally (no backend endpoint
/// for this yet — it's personal draft state, not something to sync).
class TripNotifier extends StateNotifier<List<String>> {
  TripNotifier() : super([]) {
    _load();
  }

  static const _key = 'trip_location_ids_v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) state = (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  bool contains(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    state = contains(id) ? state.where((x) => x != id).toList() : [...state, id];
    await _persist();
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, List<String>>((ref) => TripNotifier());
