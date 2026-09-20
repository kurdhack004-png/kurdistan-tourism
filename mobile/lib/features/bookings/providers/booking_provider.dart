import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking.dart';

class BookingNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  BookingNotifier(this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  final Ref _ref;
  static const _localKey = 'local_bookings_v1';

  Future<void> refresh() async {
    try {
      final api = _ref.read(apiClientProvider);
      final res = await api.client.get('/bookings');
      final raw = res.data is Map ? res.data['data'] : null;
      final list = raw is Map ? raw['data'] : raw;
      if (list is! List) throw const FormatException('Invalid bookings response');
      final items = list.whereType<Map>()
          .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      state = AsyncValue.data(items);
      return;
    } catch (_) {
      state = AsyncValue.data(await _loadLocal());
    }
  }

  Future<List<Booking>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_localKey) ?? const <String>[];
    return raw.map((value) {
      final p = value.split('|');
      return Booking(
        id: p[0], accommodationName: p[1], checkIn: DateTime.parse(p[2]),
        checkOut: DateTime.parse(p[3]), guests: int.parse(p[4]),
        totalPrice: double.parse(p[5]), status: p[6],
      );
    }).toList();
  }

  Future<void> _saveLocal(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await _loadLocal();
    items.insert(0, booking);
    await prefs.setStringList(_localKey, items.map((b) =>
      '${b.id}|${b.accommodationName}|${b.checkIn.toIso8601String()}|${b.checkOut.toIso8601String()}|${b.guests}|${b.totalPrice}|${b.status}'
    ).toList());
  }

  Future<Booking> createAndPay({
    required String accommodationId,
    required String accommodationName,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String method,
    required double total,
  }) async {
    try {
      final api = _ref.read(apiClientProvider);
      final bookingRes = await api.client.post('/bookings', data: {
        'accommodation_id': accommodationId,
        'check_in': checkIn.toIso8601String().split('T').first,
        'check_out': checkOut.toIso8601String().split('T').first,
        'guests': guests,
      });
      final booking = Booking.fromJson(bookingRes.data['data'] as Map<String, dynamic>);
      await api.client.post('/bookings/${booking.id}/pay', data: {
        'method': method,
        'idempotency_key': const Uuid().v4(),
      });
      await refresh();
      return booking;
    } catch (_) {
      // Never manufacture a "confirmed" booking when the payment server is
      // unavailable. Save it locally as pending so the user can retry later.
      final booking = Booking(
        id: 'KT-PENDING-${DateTime.now().millisecondsSinceEpoch}',
        accommodationName: accommodationName,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        totalPrice: total,
        status: 'pending_payment',
      );
      await _saveLocal(booking);
      state = AsyncValue.data(await _loadLocal());
      return booking;
    }
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, AsyncValue<List<Booking>>>(
  (ref) => BookingNotifier(ref),
);
