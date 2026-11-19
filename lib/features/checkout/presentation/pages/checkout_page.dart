import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/constants/indonesia_provinces.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/utils/validators.dart';
import 'package:w51/core/widgets/app_dropdown_field.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/picker_field.dart';
import 'package:w51/core/widgets/step_progress_header.dart';
import 'package:w51/features/cart/domain/entities/cart_item.dart';
import 'package:w51/features/cart/presentation/providers/cart_provider.dart';
import 'package:w51/features/checkout/domain/entities/checkout_details.dart';
import 'package:w51/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_bar.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_package_card.dart';
import 'package:w51/features/checkout/presentation/widgets/checkout_section.dart';
import 'package:w51/features/checkout/presentation/widgets/deal_protection_card.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({this.isCustom = false, super.key});

  /// True bila ini checkout Custom Order (gabungan vendor pilihan).
  final bool isCustom;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateKey = GlobalKey();

  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _venueName = TextEditingController();
  final _venueAddress = TextEditingController();
  final _venueCity = TextEditingController();
  final _venueMaps = TextEditingController();
  final _guests = TextEditingController();
  final _notes = TextEditingController();

  DateTime? _date;
  bool _dateError = false;
  String? _province;

  @override
  void initState() {
    super.initState();
    // Nama dan tanggal diisi dari data pasangan, tapi tetap bisa diubah.
    final couple = ref.read(coupleProvider);
    if (couple != null) {
      _bride.text = couple.brideName;
      _groom.text = couple.groomName;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Tanggal yang sudah lewat tidak ikut terisi.
      if (!couple.weddingDate.isBefore(today)) _date = couple.weddingDate;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _bride,
      _groom,
      _venueName,
      _venueAddress,
      _venueCity,
      _venueMaps,
      _guests,
      _notes,
    ]) {
      c.dispose();
    }
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
    final current = _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today) ? today : current,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateError = false;
      });
    }
  }

  /// Menggulir ke isian bermasalah yang paling atas.
  void _scrollToFirstProblem() {
    final candidates = <BuildContext>[];

    void visit(Element element) {
      final state = element is StatefulElement ? element.state : null;
      if (state is FormFieldState && state.hasError) {
        candidates.add(element);
        return;
      }
      element.visitChildElements(visit);
    }

    final formContext = _formKey.currentContext;
    if (formContext is Element) formContext.visitChildElements(visit);

    final dateContext = _dateKey.currentContext;
    if (_dateError && dateContext != null) candidates.add(dateContext);
    if (candidates.isEmpty) return;

    double top(BuildContext c) {
      final box = c.findRenderObject();
      return box is RenderBox ? box.localToGlobal(Offset.zero).dy : 0;
    }

    candidates.sort((a, b) => top(a).compareTo(top(b)));
    Scrollable.ensureVisible(
      candidates.first,
      duration: const Duration(milliseconds: 300),
      alignment: 0.15,
    );
  }

  void _submit(CartItem item) {
    final formOk = _formKey.currentState?.validate() ?? false;
    final date = _date;
    final province = _province;
    final guests = int.tryParse(_guests.text.trim());

    setState(() {
      _dateError = date == null;
    });

    if (!formOk || date == null || province == null || guests == null) {
      _snack('Periksa kembali isian yang ditandai merah.');
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToFirstProblem(),
      );
      return;
    }

    final maps = _venueMaps.text.trim();
    ref.read(checkoutProvider.notifier).save(
          CheckoutDetails(
            vendorId: item.vendorId,
            brideName: _bride.text.trim(),
            groomName: _groom.text.trim(),
            eventDate: date,
            venueName: _venueName.text.trim(),
            venueAddress: _venueAddress.text.trim(),
            venueCity: _venueCity.text.trim(),
            venueProvince: province,
            venueMaps: maps.isEmpty ? null : maps,
            guestCount: guests,
            notes: _notes.text.trim(),
          ),
        );
    context.push(AppRoutes.payment);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final selected = cart.selected;
    final item = widget.isCustom
        ? cart.customOrderItem
        : (selected.isEmpty ? null : selected.first);
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
                    message: 'Belum ada pesanan yang dipilih di keranjang.',
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
                const StepProgressHeader(
                  step: 1,
                  total: 2,
                  caption: 'Validasi Detail Acara',
                ),
                Expanded(
                  child: _buildForm(
                    item,
                    widget.isCustom ? 0 : selected.length - 1,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: item == null || keyboardOpen
          ? null
          : CheckoutBar(total: item.price, onContinue: () => _submit(item)),
    );
  }

  /// SingleChildScrollView + Column (bukan ListView) supaya SEMUA isian
  /// terpasang dan ikut diperiksa saat validasi, termasuk yang belum terlihat.
  Widget _buildForm(CartItem item, int otherCount) {
    const gap = SizedBox(height: AppSpacing.md);
    final capacity = item.guestCapacity;
    final date = _date;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckoutPackageCard(item: item, otherCount: otherCount),
            gap,
            CheckoutSection(
              icon: Icons.favorite_border,
              title: 'Data Mempelai',
              subtitle:
                  'Nama akan dicantumkan pada kontrak resmi, e-invitation, '
                  'dan plakat pernikahan.',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Nama Lengkap Pengantin Wanita',
                    required: true,
                    controller: _bride,
                    hint: 'Nama lengkap pengantin wanita',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => validateRequired(
                        v, 'Nama pengantin wanita',
                        minLength: 2),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Nama Lengkap Pengantin Pria',
                    required: true,
                    controller: _groom,
                    hint: 'Nama lengkap pengantin pria',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => validateRequired(v, 'Nama pengantin pria',
                        minLength: 2),
                  ),
                ],
              ),
            ),
            gap,
            CheckoutSection(
              icon: Icons.calendar_month_outlined,
              title: 'Waktu Acara',
              subtitle:
                  'Pilih tanggal pelaksanaan dan estimasi jumlah tamu undangan.',
              child: Column(
                children: [
                  PickerField(
                    key: _dateKey,
                    label: 'Tanggal Pelaksanaan',
                    required: true,
                    icon: Icons.calendar_today_outlined,
                    value: date == null ? 'Pilih tanggal' : formatDateId(date),
                    errorText: _dateError ? 'Pilih tanggal pelaksanaan' : null,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Perkiraan Jumlah Tamu',
                    required: true,
                    controller: _guests,
                    hint: 'Contoh: 150',
                    helperText: capacity == null
                        ? 'Perkiraan jumlah tamu yang hadir.'
                        : 'Kapasitas paket ini hingga $capacity tamu.',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => validateGuestCount(v, capacity: capacity),
                  ),
                ],
              ),
            ),
            gap,
            CheckoutSection(
              icon: Icons.place_outlined,
              title: 'Lokasi Acara',
              subtitle: 'Tempat pelaksanaan akad dan resepsi.',
              child: Column(
                children: [
                  AppTextField(
                    label: 'Nama Venue / Gedung',
                    required: true,
                    controller: _venueName,
                    hint: 'Contoh: Gedung Serbaguna Nusa',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        validateRequired(v, 'Nama venue', minLength: 3),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Alamat Lengkap',
                    required: true,
                    controller: _venueAddress,
                    maxLines: 3,
                    hint: 'Jalan, nomor, kelurahan, kecamatan',
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) =>
                        validateRequired(v, 'Alamat', minLength: 10),
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Kota / Kabupaten',
                    required: true,
                    controller: _venueCity,
                    hint: 'Contoh: Badung',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => validateRequired(v, 'Kota', minLength: 3),
                  ),
                  const SizedBox(height: 14),
                  AppDropdownField(
                    label: 'Provinsi',
                    required: true,
                    items: kIndonesianProvinces,
                    value: _province,
                    hint: 'Pilih provinsi',
                    onChanged: (v) => setState(() => _province = v),
                    validator: (v) =>
                        v == null ? 'Provinsi wajib dipilih' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Tautan Google Maps (Opsional)',
                    controller: _venueMaps,
                    keyboardType: TextInputType.url,
                    hint: 'https://maps.app.goo.gl/...',
                    validator: validateOptionalUrl,
                  ),
                ],
              ),
            ),
            gap,
            CheckoutSection(
              icon: Icons.edit_note,
              title: 'Catatan Khusus',
              trailing: const Text(
                'Opsional',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              child: AppTextField(
                label: 'Catatan',
                controller: _notes,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                hint: 'Contoh: catatan khusus untuk dekorasi atau susunan acara.',
              ),
            ),
            gap,
            const DealProtectionCard(),
          ],
        ),
      ),
    );
  }
}
