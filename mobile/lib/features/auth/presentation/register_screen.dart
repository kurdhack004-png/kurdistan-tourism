import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shell/main_shell.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  String? _localError;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().length < 2) {
      setState(() => _localError = 'تکایە ناوی تەواو بنووسە');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _localError = 'تکایە ئیمەیلێکی دروست بنووسە');
      return;
    }
    if (_passCtrl.text != _passConfirmCtrl.text) {
      setState(() => _localError = 'وشەی نهێنی وەک یەک نییە');
      return;
    }
    if (_passCtrl.text.length < 10) {
      setState(() => _localError = 'وشەی نهێنی دەبێت لانیکەم ١٠ پیت بێت');
      return;
    }
    setState(() => _localError = null);

    await ref.read(authProvider.notifier).register(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(backgroundColor: AppColors.ink, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('هەژمار دروست بکە',
                  style: TextStyle(color: AppColors.limestoneWhite, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.xl),
              _field(_nameCtrl, 'ناوی تەواو'),
              const SizedBox(height: AppSpacing.md),
              _field(_emailCtrl, 'ئیمەیل', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppSpacing.md),
              _field(_passCtrl, 'وشەی نهێنی', obscure: true),
              const SizedBox(height: AppSpacing.md),
              _field(_passConfirmCtrl, 'دووبارە وشەی نهێنی', obscure: true),
              const SizedBox(height: AppSpacing.lg),
              if (_localError != null || auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(_localError ?? auth.error!,
                      style: const TextStyle(color: Color(0xFFE38E7E), fontSize: 13)),
                ),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.inkDeep))
                    : const Text('تۆمارکردن'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, {bool obscure = false, TextInputType? keyboardType}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.limestoneWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.riverstone),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
