import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/features/auth/domain/validators.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/auth/presentation/widgets/auth_layout.dart';
import 'package:w51/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:w51/core/widgets/password_field.dart';
import 'package:w51/app/router/auth_redirect.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({this.from, super.key});

  /// Alamat tujuan setelah berhasil (diteruskan dari penjaga login).
  final String? from;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  /// 'google' atau 'email' selama permintaan berjalan; null bila diam.
  String? _busy;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(String action, void Function() signIn) async {
    if (_busy != null) return;
    setState(() => _busy = action);
    // PROTOTYPE: meniru jeda jaringan. Autentikasi sungguhan menggantikan
    // bagian ini.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Ambil dulu: halaman ini bisa hilang begitu status login berubah.
    final router = GoRouter.of(context);
    final destination = postLoginDestination(
      from: widget.from,
      needsCoupleSetup: ref.read(coupleProvider) == null,
    );
    setState(() => _busy = null);
    signIn();
    // Pindah halaman secara eksplisit, tidak bergantung pada penyegaran router.
    router.go(destination);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _run(
      'email',
      () => ref
          .read(authProvider.notifier)
          .register(name: _name.text.trim(), email: _email.text.trim()),
    );
  }

  void _google() => _run('google',
      () => ref.read(authProvider.notifier).signInDemo(viaGoogle: true));

  @override
  Widget build(BuildContext context) {
    final busy = _busy != null;
    return AuthLayout(
      title: 'Mulai Rencanakan Hari Bahagia',
      subtitle: 'Buat akun untuk menyimpan keranjang, memesan vendor, dan '
          'mengatur persiapan pernikahanmu.',
      onBack: context.canPop() ? context.pop : null,
      fields: [
        GoogleSignInButton(
          label: 'Daftar dengan Google',
          loading: _busy == 'google',
          onPressed: busy ? null : _google,
        ),
        const AuthDivider('atau daftar dengan email'),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nama Lengkap',
                controller: _name,
                hint: 'Nama kamu',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 14),
              PasswordField(
                label: 'Kata Sandi',
                controller: _password,
                hint: 'Buat kata sandi',
                helperText: 'Minimal 8 karakter, kombinasi huruf dan angka.',
                textInputAction: TextInputAction.next,
                validator: validateNewPassword,
              ),
              const SizedBox(height: 14),
              PasswordField(
                label: 'Ulangi Kata Sandi',
                controller: _confirm,
                hint: 'Ketik ulang kata sandi',
                validator: (v) => validateConfirmPassword(v, _password.text),
                onSubmitted: (_) => busy ? null : _submit(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: busy ? null : _submit,
                child: _busy == 'email'
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Buat Akun'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Mode prototype: akun belum tersimpan di server.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
      footer: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Sudah punya akun?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => context.pushReplacement(
                          AppRoutes.loginPath(from: widget.from),
                        ),
                child: const Text('Masuk'),
              ),
            ],
          ),
          TextButton(
            onPressed: busy ? null : () => context.go(AppRoutes.home),
            child: const Text('Lanjut sebagai tamu'),
          ),
        ],
      ),
    );
  }
}
