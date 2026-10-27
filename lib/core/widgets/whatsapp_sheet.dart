import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/utils/whatsapp.dart';

/// Lembar chat WhatsApp: pesan terisi, bisa diedit, dibuka, atau disalin.
/// Bila nomor tidak ada atau WhatsApp gagal dibuka, pesan disalin.
Future<void> showWhatsAppSheet(
  BuildContext context, {
  required String title,
  required String? phone,
  required String message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    builder: (_) =>
        _WhatsAppSheet(title: title, phone: phone, message: message),
  );
}

class _WhatsAppSheet extends StatefulWidget {
  const _WhatsAppSheet({
    required this.title,
    required this.phone,
    required this.message,
  });

  final String title;
  final String? phone;
  final String message;

  @override
  State<_WhatsAppSheet> createState() => _WhatsAppSheetState();
}

class _WhatsAppSheetState extends State<_WhatsAppSheet> {
  late final TextEditingController _message = TextEditingController(
    text: widget.message,
  );
  String? _error;
  bool _opening = false;

  String? get _number {
    final p = widget.phone;
    return p == null ? null : normalizeWhatsAppNumber(p);
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    final text = _message.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Tulis pesan terlebih dahulu.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Pesan disalin.')));
  }

  Future<void> _open() async {
    if (_opening) return;
    final text = _message.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Tulis pesan terlebih dahulu.');
      return;
    }
    final number = _number;
    if (number == null) return;

    setState(() => _opening = true);
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await launchUrl(
        whatsAppUri(number, text),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened) await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    Navigator.of(context).pop();
    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('WhatsApp tidak bisa dibuka. Pesan sudah disalin.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final number = _number;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + inset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: AppTypography.heading(22)),
            const SizedBox(height: 4),
            Text(
              number == null
                  ? 'Nomor WhatsApp belum tersedia. Kamu masih bisa menyalin '
                      'pesannya.'
                  : 'Dikirim ke WhatsApp +$number',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _message,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: 'Tulis pesan',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Salin'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (number == null || _opening) ? null : _open,
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('Buka WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
