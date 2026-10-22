import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/auth_redirect.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/core/widgets/picker_field.dart';
import 'package:w51/features/auth/domain/validators.dart';
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
  DateTime? _date;
  bool _dateError = false;
  late final bool _editing;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(coupleProvider);
    _editing = existing != null;
    if (existing != null) {
      _bride.text = existing.brideName;
      _groom.text = existing.groomName;
      _date = existing.weddingDate;
    }
  }

  @override
  void dispose() {
    _bride.dispose();
    _groom.dispose();
    super.dispose();
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

  void _save() {
    final formOk = _formKey.currentState?.validate() ?? false;
    final date = _date;
    if (date == null) setState(() => _dateError = true);
    if (!formOk || date == null) return;

    ref.read(coupleProvider.notifier).save(
          CoupleProfile(
            brideName: _bride.text,
            groomName: _groom.text,
            weddingDate: date,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    _finish();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
          const SnackBar(content: Text('Data pernikahan tersimpan.')));
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    return AuthLayout(
      title: _editing ? 'Ubah Data Pernikahan' : 'Ceritakan Pernikahanmu',
      subtitle:
          'Kami memakainya untuk hitung mundur dan mengisi data pesananmu '
          'otomatis. Bisa diubah kapan saja.',
      onBack: context.canPop() ? context.pop : null,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Nama Pengantin Wanita',
                required: true,
                controller: _bride,
                hint: 'Nama lengkap',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Nama Pengantin Pria',
                required: true,
                controller: _groom,
                hint: 'Nama lengkap',
                textCapitalization: TextCapitalization.words,
                validator: validateName,
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
              FilledButton(onPressed: _save, child: const Text('Simpan')),
            ],
          ),
        ),
      ],
      footer: _editing
          ? const SizedBox.shrink()
          : TextButton(onPressed: _finish, child: const Text('Lewati dulu')),
    );
  }
}
