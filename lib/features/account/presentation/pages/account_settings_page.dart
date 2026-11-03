import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/password_field.dart';
import 'package:w51/core/widgets/picker_field.dart';
import 'package:w51/features/account/presentation/providers/account_provider.dart';
import 'package:w51/features/auth/domain/validators.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final _nameForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _savingName = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(authProvider)?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _snack(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveName() async {
    if (_savingName) return;
    if (!(_nameForm.currentState?.validate() ?? false)) return;

    setState(() => _savingName = true);
    final auth = ref.read(authProvider.notifier);
    final repository = ref.read(accountRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await repository.updateName(_name.text);
      auth.updateName(saved);
      if (mounted) _name.text = saved;
      _snack(messenger, 'Nama diperbarui.');
    } on ValidationException catch (e) {
      _snack(messenger, e.message);
    } catch (_) {
      _snack(messenger, 'Gagal menyimpan. Periksa koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _savePassword() async {
    if (_savingPassword) return;
    if (!(_passwordForm.currentState?.validate() ?? false)) return;

    setState(() => _savingPassword = true);
    final repository = ref.read(accountRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await repository.changePassword(
        current: _current.text,
        password: _password.text,
      );
      if (mounted) {
        _current.clear();
        _password.clear();
        _confirm.clear();
        _passwordForm.currentState?.reset();
      }
      _snack(messenger, 'Kata sandi diperbarui (mode prototype).');
    } on ValidationException catch (e) {
      _snack(messenger, e.message);
    } catch (_) {
      _snack(messenger, 'Gagal menyimpan. Periksa koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    final appBar = AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        tooltip: 'Kembali',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.myWedding);
          }
        },
        icon: const Icon(Icons.arrow_back),
      ),
      centerTitle: true,
      title: Text('Pengaturan Akun', style: AppTypography.heading(20)),
    );

    if (user == null) {
      return Scaffold(
        appBar: appBar,
        body: const EmptyState(
          message: 'Kamu belum masuk.',
          icon: Icons.person_off_outlined,
        ),
      );
    }

    final initial =
        user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase();

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.surfaceTint,
                  child: Text(initial, style: AppTypography.heading(30)),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading(22),
                ),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                BadgePill(
                  user.hasPassword
                      ? 'Masuk dengan email'
                      : 'Masuk dengan Google',
                  icon: user.hasPassword ? Icons.mail_outline : Icons.verified,
                  background: AppColors.surfaceTint,
                  foreground: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _Section(
              title: 'Data Akun',
              child: Form(
                key: _nameForm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Nama',
                      required: true,
                      controller: _name,
                      hint: 'Nama kamu',
                      textCapitalization: TextCapitalization.words,
                      validator: validateName,
                    ),
                    const SizedBox(height: 14),
                    PickerField(
                      label: 'Email',
                      icon: Icons.mail_outline,
                      value: user.email,
                      subtitle: 'Email tidak dapat diubah',
                      trailing: const Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: _name,
                      builder: (context, _) => FilledButton(
                        onPressed:
                            (_savingName || _name.text.trim() == user.name)
                                ? null
                                : _saveName,
                        child: _savingName
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (user.hasPassword)
              _Section(
                title: 'Ubah Kata Sandi',
                child: Form(
                  key: _passwordForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PasswordField(
                        label: 'Kata Sandi Saat Ini',
                        controller: _current,
                        textInputAction: TextInputAction.next,
                        validator: validateLoginPassword,
                      ),
                      const SizedBox(height: 14),
                      PasswordField(
                        label: 'Kata Sandi Baru',
                        controller: _password,
                        helperText:
                            'Minimal 8 karakter, kombinasi huruf dan angka.',
                        textInputAction: TextInputAction.next,
                        validator: validateNewPassword,
                      ),
                      const SizedBox(height: 14),
                      PasswordField(
                        label: 'Ulangi Kata Sandi Baru',
                        controller: _confirm,
                        validator: (v) =>
                            validateConfirmPassword(v, _password.text),
                        onSubmitted: (_) => _savePassword(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _savingPassword ? null : _savePassword,
                        child: _savingPassword
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Ubah Kata Sandi'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTint,
                  borderRadius: AppRadius.card,
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Akunmu masuk dengan Google, jadi tidak memakai kata '
                        'sandi aplikasi.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Mode prototype: perubahan belum tersimpan di server dan hilang '
              'saat aplikasi ditutup.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTypography.heading(20)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
