import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../../shell/main_shell.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _select(BuildContext context, WidgetRef ref, String code) async {
    await ref.read(settingsProvider.notifier).setLanguage(code);
    await context.setLocale(Locale(code));
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.inkDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language_rounded, color: AppColors.saffron, size: 64),
                const SizedBox(height: 24),
                Text(
                  'language'.tr(),
                  style: const TextStyle(
                    color: AppColors.limestoneWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'app_name'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.limestoneWhite, fontSize: 17),
                ),
                const SizedBox(height: 32),
                _LanguageButton(
                  label: 'کوردی',
                  subtitle: 'سۆرانی',
                  onPressed: () => _select(context, ref, 'ckb'),
                ),
                const SizedBox(height: 12),
                _LanguageButton(
                  label: 'العربية',
                  subtitle: 'العربية',
                  onPressed: () => _select(context, ref, 'ar'),
                ),
                const SizedBox(height: 12),
                _LanguageButton(
                  label: 'English',
                  subtitle: 'English',
                  onPressed: () => _select(context, ref, 'en'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          foregroundColor: AppColors.limestoneWhite,
          backgroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.riverstone),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
