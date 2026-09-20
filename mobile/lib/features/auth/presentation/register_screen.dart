import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (ref.read(authProvider).isAuthenticated) {
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
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.limestoneWhite,
        title: Text('register'.tr()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 48, color: AppColors.saffron),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'create_account'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.limestoneWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _RegisterField(
                  controller: _nameController,
                  hint: 'full_name'.tr(),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'required_name'.tr()
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _RegisterField(
                  controller: _emailController,
                  hint: 'email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                        ? null
                        : 'valid_email'.tr();
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _RegisterField(
                  controller: _passwordController,
                  hint: 'password_min'.tr(),
                  obscureText: true,
                  validator: (value) => (value?.length ?? 0) < 10
                      ? 'password_short'.tr()
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _RegisterField(
                  controller: _confirmController,
                  hint: 'confirm_password'.tr(),
                  obscureText: true,
                  validator: (value) => value != _passwordController.text
                      ? 'password_mismatch'.tr()
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      auth.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE38E7E), fontSize: 13),
                    ),
                  ),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.inkDeep,
                          ),
                        )
                      : Text('register'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.limestoneWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.riverstone),
        errorStyle: const TextStyle(color: Color(0xFFE38E7E)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
