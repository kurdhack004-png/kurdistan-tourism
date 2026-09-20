import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

/// Content that is managed from the admin dashboard (home slider, ads,
/// emergency numbers, notifications). Every provider degrades gracefully:
/// if the backend is unreachable the app keeps working with its built-in
/// defaults, exactly like the rest of the offline-first app.

dynamic _payload(dynamic body) => body is Map ? body['data'] : null;

String _str(dynamic v) => v == null ? '' : v.toString().trim();

class HeroData {
  const HeroData({this.intervalSec = 5, this.images = const <String>[]});
  final int intervalSec;
  final List<String> images;
}

class AdItem {
  const AdItem({required this.title, this.company = '', this.image = '', this.link = ''});
  final String title;
  final String company;
  final String image;
  final String link;
}

class EmergencyContact {
  const EmergencyContact(this.label, this.phone);
  final String label;
  final String phone;
}

class AppNotification {
  const AppNotification(this.title, this.body);
  final String title;
  final String body;
}

const kDefaultEmergencyContacts = <EmergencyContact>[
  EmergencyContact('پۆلیس', '104'),
  EmergencyContact('یارمەتی پزیشکی', '122'),
  EmergencyContact('بەرگری کیویڵ', '115'),
];

/// Home-screen slider: image URLs + seconds between slides.
/// Empty [HeroData.images] means "use the built-in category scenes".
final heroProvider = FutureProvider<HeroData>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.client.get('/hero');
    final data = _payload(res.data);
    if (data is! Map) return const HeroData();
    final rawImages = data['images'];
    final images = rawImages is List
        ? rawImages.map(_str).where((u) => u.startsWith('http')).toList()
        : <String>[];
    final rawInterval = data['interval_sec'];
    final interval = rawInterval is num ? rawInterval.toInt() : 5;
    return HeroData(intervalSec: interval < 1 ? 1 : (interval > 60 ? 60 : interval), images: images);
  } catch (_) {
    return const HeroData();
  }
});

/// Advertisements that are active right now.
final adsProvider = FutureProvider<List<AdItem>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.client.get('/ads');
    final data = _payload(res.data);
    if (data is! List) return const <AdItem>[];
    return data
        .whereType<Map>()
        .map((m) => AdItem(
              title: _str(m['title']),
              company: _str(m['company']),
              image: _str(m['image']),
              link: _str(m['link']),
            ))
        .where((a) => a.title.isNotEmpty)
        .toList();
  } catch (_) {
    return const <AdItem>[];
  }
});

/// Emergency numbers from the admin; falls back to the built-in defaults
/// when the backend is offline or no number has been added yet.
final emergencyProvider = FutureProvider<List<EmergencyContact>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.client.get('/emergency');
    final data = _payload(res.data);
    if (data is! List) return kDefaultEmergencyContacts;
    final items = <EmergencyContact>[];
    for (final m in data.whereType<Map>()) {
      final ku = _str(m['label_ku']);
      final label = ku.isNotEmpty ? ku : _str(m['label']);
      final phone = _str(m['phone']);
      if (label.isNotEmpty && phone.isNotEmpty) items.add(EmergencyContact(label, phone));
    }
    return items.isEmpty ? kDefaultEmergencyContacts : items;
  } catch (_) {
    return kDefaultEmergencyContacts;
  }
});

/// Notifications published from the admin. `null` means the backend could
/// not be reached (the screen then shows its offline placeholders).
final notificationsProvider = FutureProvider<List<AppNotification>?>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.client.get('/notifications');
    final data = _payload(res.data);
    if (data is! List) return null;
    return data
        .whereType<Map>()
        .map((m) => AppNotification(_str(m['title']), _str(m['body'])))
        .where((n) => n.title.isNotEmpty)
        .toList();
  } catch (_) {
    return null;
  }
});
