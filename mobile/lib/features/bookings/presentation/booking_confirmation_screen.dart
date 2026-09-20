import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/booking.dart';
import '../../shell/main_shell.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  booking.status == 'pending_payment' ? Icons.schedule_rounded : Icons.check_circle_rounded,
                  color: booking.status == 'pending_payment' ? AppColors.saffron : AppColors.clay,
                  size: 84,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(booking.status == 'pending_payment' ? 'offline_pending_payment'.tr() : 'booking_confirmed'.tr(), style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${booking.accommodationName} • ${booking.guests} میوان',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()), (route) => false),
                    child: Text('back_to_app'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
