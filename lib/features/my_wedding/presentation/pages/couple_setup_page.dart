import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/auth_redirect.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/core/widgets/picker_field.dart';
import 'package:w51/features/auth/domain/validators.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/auth/presentation/widgets/auth_layout.dart';
import 'package:w51/features/my_wedding/domain/entities/couple_profile.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

class CoupleSetupPage extends ConsumerStatefulWidget {
  const CoupleSetupPage({this.from, super.key});

  /// Tujuan setelah selesai atau dilewati. Kosong berarti kembali ke halaman
  /// sebelumnya (mis. dibuka dari Profil).
  final String? from;

  @override
  ConsumerState<CoupleSetupPage> createState() => _CoupleSetupPageState();
}

class _CoupleSetupPageState extends ConsumerState<CoupleSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _bridePhone = TextEditingController();
  final _groomPhone = TextEditingController();
  DateTime? _date;
  bool _dateError = false;
  bool _saving = false;
  late final bool _editing;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(coupleProvider);
    _editing = existing != null;
    if (existing != null) {
      _bride.text = existing.brideName;
      _groom.text = existing.groomName;
      _bridePhone.text = existing.bridePhone ?? '';
      _groomPhone.text = existing.groomPhone ?? '';
      _date = existing.weddingDate;
    } else {
      _date = DateTime.now().add(const Duration(days: 90));
    }
  }

  @override
  void dispose() {
    _bride.dispose();
    _groom.dispose();
    _bridePhone.dispose();
    _groomPhone.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nomor telepon wajib diisi';
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
      return 'Masukkan 10-15 digit angka';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
      helpText: 'Pilih tanggal pernikahan',
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateError = false;
    });
  }

  void _finish() {
    if (widget.from == null && context.canPop()) {
      context.pop();
    } else {
      context.go(safeInternalPath(widget.from));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final formOk = _formKey.currentState?.validate() ?? false;
    final date = _date;
    if (date == null) setState(() => _dateError = true);
    if (!formOk || date == null) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final userEmail = ref.read(authProvider)?.email;

    try {
      await ref.read(coupleProvider.notifier).save(
            CoupleProfile(
              brideName: _bride.text,
              groomName: _groom.text,
              bridePhone: _bridePhone.text,
              groomPhone: _groomPhone.text,
              email: userEmail,
              weddingDate: date,
            ),
          );
      if (!mounted) return;
      _finish();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Data mempelai berhasil disimpan.')),
        );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              userMessage(e, fallback: 'Gagal menyimpan data mempelai.'),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    return AuthLayout(
      title: _editing ? 'Ubah Data Pernikahan' : 'Lengkapi Data Mempelai',
      subtitle:
          'Kami memakainya untuk hitung mundur dan mengisi data pesananmu '
          'otomatis sesuai akun MyDream.',
      onBack: context.canPop() ? context.pop : null,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nama Mempelai Pria',
                required: true,
                controller: _groom,
                hint: 'Masukkan nama mempelai pria',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Nama Mempelai Wanita',
                required: true,
                controller: _bride,
                hint: 'Masukkan nama mempelai wanita',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'No. Telepon Mempelai Pria',
                required: true,
                controller: _groomPhone,
                hint: 'Contoh: 081234567890',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'No. Telepon Mempelai Wanita',
                required: true,
                controller: _bridePhone,
                hint: 'Contoh: 081234567890',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 14),
              PickerField(
                label: 'Tanggal Pernikahan',
                required: true,
                icon: Icons.calendar_today_outlined,
                value: date == null ? 'Pilih tanggal' : formatDateId(date),
                errorText: _dateError ? 'Pilih tanggal pernikahan' : null,
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              const Text(
                'Belum pasti? Perkiraan tanggal juga boleh.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan dan Lanjutkan'),
              ),
            ],
          ),
        ),
      ],
      footer: _editing
          ? const SizedBox.shrink()
          : TextButton(
              onPressed: _saving ? null : _finish,
              child: const Text('Lewati dulu'),
            ),
    );
  }
}
