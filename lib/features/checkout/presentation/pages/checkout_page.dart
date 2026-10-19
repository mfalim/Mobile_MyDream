import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/picker_field.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/domain/entities/checkout_options.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_bar.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_package_card.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_section.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_step_header.dart';
import 'package:w51/features/checkout/presentation/widgets/concept_selector.dart';
import 'package:w51/features/checkout/presentation/widgets/deal_protection_card.dart';
import 'package:w51/features/checkout/presentation/widgets/guest_tier_selector.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _hall = TextEditingController();
  final _pic = TextEditingController();
  final _whatsapp = TextEditingController();
  final _notes = TextEditingController();

  // MOCK: nilai awal. Nanti diambil dari data pasangan / slot vendor.
  DateTime _date = DateTime(2026, 10, 24);
  TimeOfDay _ceremony = const TimeOfDay(hour: 15, minute: 30);
  TimeOfDay _reception = const TimeOfDay(hour: 18, minute: 30);
  int _tier = 0;
  int _concept = 0;

  @override
  void dispose() {
    _bride.dispose();
    _groom.dispose();
    _hall.dispose();
    _pic.dispose();
    _whatsapp.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.cart);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime({required bool ceremony}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: ceremony ? _ceremony : _reception,
    );
    if (picked == null) return;
    setState(() {
      if (ceremony) {
        _ceremony = picked;
      } else {
        _reception = picked;
      }
    });
  }

  String _time(TimeOfDay t) => formatTimeWita(t.hour, t.minute);

  void _submit(CartItem item) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _snack('Lengkapi data yang wajib diisi.');
      return;
    }
    final ceremonyMinutes = _ceremony.hour * 60 + _ceremony.minute;
    final receptionMinutes = _reception.hour * 60 + _reception.minute;
    if (receptionMinutes <= ceremonyMinutes) {
      _snack('Waktu resepsi harus setelah waktu akad.');
      return;
    }

    final tier = kGuestTiers[_tier];
    ref.read(checkoutProvider.notifier).save(
          CheckoutDetails(
            vendorId: item.vendorId,
            brideName: _bride.text.trim(),
            groomName: _groom.text.trim(),
            eventDate: _date,
            ceremonyTime: _time(_ceremony),
            receptionTime: _time(_reception),
            city: item.location,
            hallDetail: _hall.text.trim(),
            guestCount: tier.guests,
            guestExtraCost: tier.extraCost,
            concept: kWeddingConcepts[_concept],
            picName: _pic.text.trim(),
            whatsapp: '+62${_whatsapp.text.trim()}',
            notes: _notes.text.trim(),
          ),
        );
    context.push(AppRoutes.payment);
  }

  String? _requiredName(String? value, String label) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label wajib diisi';
    if (v.length < 2) return '$label terlalu pendek';
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (v.startsWith('0')) {
      return 'Tulis tanpa angka 0 di depan (contoh: 811...)';
    }
    if (v.length < 9 || v.length > 13) {
      return 'Nomor harus 9–13 digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final selected = cart.selected;
    final item = selected.isEmpty ? null : selected.first;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Wedding Checkout', style: AppTypography.heading(20)),
      ),
      body: item == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyState(
                    message: 'Belum ada paket yang dipilih di keranjang.',
                    icon: Icons.shopping_bag_outlined,
                  ),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.cart),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                    child: const Text('Kembali ke Keranjang'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const CheckoutStepHeader(
                  step: 1,
                  total: 2,
                  caption: 'Validasi Detail Acara',
                ),
                Expanded(child: _buildForm(item, selected.length - 1)),
              ],
            ),
      bottomNavigationBar: item == null || keyboardOpen
          ? null
          : CheckoutBar(
              total: item.price + kGuestTiers[_tier].extraCost,
              onContinue: () => _submit(item),
            ),
    );
  }

  Widget _buildForm(CartItem item, int otherCount) {
    const gap = SizedBox(height: AppSpacing.md);

    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.lg,
        ),
        children: [
          CheckoutPackageCard(item: item, otherCount: otherCount),
          gap,
          CheckoutSection(
            icon: Icons.favorite_border,
            title: 'Data Mempelai',
            subtitle:
                'Nama akan dicantumkan pada kontrak resmi, e-invitation, dan '
                'plakat pernikahan.',
            child: Column(
              children: [
                AppTextField(
                  label: 'Nama Lengkap Pengantin Wanita',
                  required: true,
                  controller: _bride,
                  hint: 'Nama lengkap pengantin wanita',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _requiredName(v, 'Nama pengantin wanita'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Nama Lengkap Pengantin Pria',
                  required: true,
                  controller: _groom,
                  hint: 'Nama lengkap pengantin pria',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _requiredName(v, 'Nama pengantin pria'),
                ),
              ],
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.calendar_month_outlined,
            title: 'Jadwal Acara & Waktu',
            child: Column(
              children: [
                PickerField(
                  label: 'Tanggal Pelaksanaan (Akad & Resepsi)',
                  required: true,
                  icon: Icons.calendar_today_outlined,
                  value: formatDateId(_date),
                  subtitle: 'Slot Musim Pernikahan Tersedia',
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PickerField(
                        label: 'Waktu Akad / Vow',
                        icon: Icons.schedule,
                        value: _time(_ceremony),
                        onTap: () => _pickTime(ceremony: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PickerField(
                        label: 'Waktu Resepsi',
                        icon: Icons.schedule,
                        value: _time(_reception),
                        onTap: () => _pickTime(ceremony: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.place_outlined,
            title: 'Lokasi & Venue Pilihan',
            child: Column(
              children: [
                PickerField(
                  label: 'Kota & Destinasi Acara',
                  icon: Icons.explore_outlined,
                  value: item.location,
                  trailing: const BadgePill(
                    'LOCKED PACKAGE',
                    background: AppColors.outline,
                    foreground: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Detail Area / Hall Tambahan (Opsional)',
                  controller: _hall,
                  hint: 'Contoh: Sunset Lawn & Outdoor Glass House',
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.groups_outlined,
            title: 'Estimasi Jumlah Tamu',
            trailing: const BadgePill(
              'Kapasitas Maksimal',
              background: AppColors.surfaceTint,
              foreground: AppColors.textSecondary,
            ),
            child: GuestTierSelector(
              tiers: kGuestTiers,
              selectedIndex: _tier,
              onChanged: (i) => setState(() => _tier = i),
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.palette_outlined,
            title: 'Konsep & Nuansa Pernikahan',
            subtitle: 'Pilih tema moodboard agar florist dan dekorator dapat '
                'mempersiapkan mock-up palet.',
            child: ConceptSelector(
              concepts: kWeddingConcepts,
              selectedIndex: _concept,
              onChanged: (i) => setState(() => _concept = i),
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.contact_phone_outlined,
            title: 'Kontak Penanggung Jawab (PIC)',
            child: Column(
              children: [
                AppTextField(
                  label: 'Nama Lengkap PIC / Keluarga',
                  required: true,
                  controller: _pic,
                  hint: 'Nama penanggung jawab',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _requiredName(v, 'Nama PIC'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Nomor WhatsApp Aktif',
                  required: true,
                  controller: _whatsapp,
                  hint: '811 9874 3210',
                  prefixText: '+62  ',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  helperText:
                      'Update timeline rundown & surat konfirmasi venue akan '
                      'dikirim via nomor ini.',
                  validator: _validateWhatsapp,
                ),
              ],
            ),
          ),
          gap,
          CheckoutSection(
            icon: Icons.edit_note,
            title: 'Catatan Khusus Vendor',
            trailing: const Text(
              'Opsional',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            child: AppTextField(
              label: 'Catatan',
              controller: _notes,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              hint: 'Contoh: mohon penyesuaian menu canapé untuk 15 tamu vegan '
                  'dan preferensi warna bunga.',
            ),
          ),
          gap,
          const DealProtectionCard(),
        ],
      ),
    );
  }
}
