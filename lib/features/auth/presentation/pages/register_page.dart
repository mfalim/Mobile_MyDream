import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/errors/app_exceptions.dart';
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  /// Daftar/masuk dengan Google — sama dengan LoginPage, karena API Laravel
  /// menggunakan createOrLogin (buat akun baru bila belum ada).
  Future<void> _google() async {
    if (_busy != null) return;
    setState(() => _busy = 'google');

    try {
      final result =
          await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      final router = GoRouter.of(context);

      if (result.nextStep == 'complete_profile') {
        final dest = result.user.role == 'client'
            ? AppRoutes.coupleSetupPath(from: widget.from ?? AppRoutes.home)
            : safeInternalPath(widget.from);
        router.go(dest);
      } else {
        final dest = postLoginDestination(
          from: widget.from,
          needsCoupleSetup: ref.read(coupleProvider) == null &&
              result.user.role == 'client',
        );
        router.go(dest);
      }
    } on UnauthorizedException catch (e) {
      _showError(e.message);
    } on ServerException catch (e) {
      _showError(e.message);
    } on NetworkException catch (e) {
      _showError(e.message);
    } on GoogleSignInException catch (e) {
      _showError(
        e.description ??
            (e.code == GoogleSignInExceptionCode.canceled
                ? 'Login dibatalkan atau SHA-1 belum cocok di Google Cloud Console.'
                : 'Google Sign-In gagal: ${e.code.name}'),
      );
    } catch (e) {
      _showError('Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Email/password register belum terhubung ke API — tampilkan info
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daftar email belum tersedia. Gunakan Google.')),
    );
  }

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
