import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import 'payment_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
    required this.pricePerNight,
  });

  final String accommodationId;
  final String accommodationName;
  final double pricePerNight;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  int _guests = 2;

  static const double _bookingFee = 10000;
  int get _nights => _checkOut.difference(_checkIn).inDays.clamp(1, 365);
  double get _roomTotal => _nights * widget.pricePerNight;
  double get _total => _roomTotal + _bookingFee;

  Future<void> _pickDate({required bool isCheckIn}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  Future<void> _continueToPayment() async {
    if (!ref.read(authProvider).isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !ref.read(authProvider).isAuthenticated) return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          accommodationId: widget.accommodationId,
          accommodationName: widget.accommodationName,
          checkIn: _checkIn,
          checkOut: _checkOut,
          guests: _guests,
          total: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('booking'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            widget.accommodationName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text('check_in'.tr()),
              subtitle: Text(_fmt(_checkIn)),
              onTap: () => _pickDate(isCheckIn: true),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text('check_out'.tr()),
              subtitle: Text(_fmt(_checkOut)),
              onTap: () => _pickDate(isCheckIn: false),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text('guests'.tr()),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'remove_guest'.tr(),
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _guests > 1
                          ? () => setState(() => _guests--)
                          : null,
                    ),
                    Text('$_guests', style: const TextStyle(fontSize: 15)),
                    IconButton(
                      tooltip: 'add_guest'.tr(),
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _guests < 20
                          ? () => setState(() => _guests++)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.saffron.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$_nights ${'nights'.tr()}'),
                    Text('${_roomTotal.toStringAsFixed(0)} ${'iqd'.tr()}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('booking_fee'.tr()),
                    Text('${_bookingFee.toStringAsFixed(0)} ${'iqd'.tr()}'),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total'.tr(), style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${_total.toStringAsFixed(0)} ${'iqd'.tr()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _continueToPayment,
            child: Text('continue_payment'.tr()),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
