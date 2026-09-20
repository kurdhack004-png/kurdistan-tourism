import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'booking_confirmation_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.accommodationId,
    required this.accommodationName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.total,
  });

  final String accommodationId;
  final String accommodationName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double total;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

const _methods = [
  ('fib', 'fib', Icons.account_balance_wallet_outlined),
  ('visa', 'card', Icons.credit_card_outlined),
  ('cash', 'cash', Icons.payments_outlined),
  ('bank_transfer', 'bank_transfer', Icons.account_balance_outlined),
];

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _submitting = false;
  String? _error;

  Future<void> _pay(String method) async {
    if (!ref.read(authProvider).isAuthenticated) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (!mounted || !ref.read(authProvider).isAuthenticated) return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final booking = await ref.read(bookingProvider.notifier).createAndPay(
            accommodationId: widget.accommodationId,
            accommodationName: widget.accommodationName,
            checkIn: widget.checkIn,
            checkOut: widget.checkOut,
            guests: widget.guests,
            method: method,
            total: widget.total,
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(booking: booking),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'payment_failed'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('payment_method'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            '${'total'.tr()}: ${widget.total.toStringAsFixed(0)} ${'iqd'.tr()}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          for (final m in _methods)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                leading: Icon(m.$3, color: AppColors.clay),
                title: Text(m.$2.tr()),
                trailing: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_left_rounded),
                onTap: _submitting ? null : () => _pay(m.$1),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'payment_note'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
