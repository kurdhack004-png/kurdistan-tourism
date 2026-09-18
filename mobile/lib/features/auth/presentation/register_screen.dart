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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.limestoneWhite,
        title: const Text('تۆمارکردنی هەژمار'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1_rounded,
                    size: 48, color: AppColors.saffron),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'هەژمارێکی نوێ دروست بکە',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.limestoneWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DarkField(
                  controller: _nameCtrl,
                  hint: 'ناوی تەواو',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'تکایە ناوی تەواو بنووسە'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _DarkField(
                  controller: _emailCtrl,
                  hint: 'ئیمەیل',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty || !email.contains('@')) {
                      return 'تکایە ئیمەیلی دروست بنووسە';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _DarkField(
                  controller: _passwordCtrl,
                  hint: 'وشەی نهێنی (کەمتر نەبێت لە ١٠ پیت)',
                  obscure: true,
                  validator: (value) => (value?.length ?? 0) < 10
                      ? 'وشەی نهێنی دەبێت لانیکەم ١٠ پیت بێت'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _DarkField(
                  controller: _confirmPasswordCtrl,
                  hint: 'دووبارەکردنەوەی وشەی نهێنی',
                  obscure: true,
                  validator: (value) => value != _passwordCtrl.text
                      ? 'وشەی نهێنی یەکسان نییە'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      auth.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFE38E7E), fontSize: 13),
                    ),
                  ),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.inkDeep),
                        )
                      : const Text('تۆمارکردن'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.limestoneWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.riverstone),
        errorStyle: const TextStyle(color: Color(0xFFE38E7E)),
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
