import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:w51/core/config/app_config.dart';
import 'package:w51/core/utils/chat_messages.dart';
import 'package:w51/core/widgets/whatsapp_sheet.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/features/vendors/presentation/providers/vendors_provider.dart';

/// Chat ke vendor lewat WhatsApp (nomor dari data vendor).
Future<void> contactVendor(
  BuildContext context,
  WidgetRef ref,
  String vendorId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final date = ref.read(coupleProvider)?.weddingDate;
  try {
    final vendor = await ref.read(vendorDetailProvider(vendorId).future);
    if (!context.mounted) return;
    await showWhatsAppSheet(
      context,
      title: 'Chat ${vendor.name}',
      phone: vendor.phone,
      message: vendorInquiryMessage(
        vendorName: vendor.name,
        category: vendor.category,
        weddingDate: date,
      ),
    );
  } catch (_) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Kontak vendor tidak bisa dimuat. Coba lagi.'),
        ),
      );
  }
}

/// Chat ke admin Aura Wedding lewat WhatsApp.
void contactAdmin(BuildContext context, WidgetRef ref, {String? topic}) {
  final date = ref.read(coupleProvider)?.weddingDate;
  showWhatsAppSheet(
    context,
    title: 'Chat Admin Aura Wedding',
    phone: AppConfig.adminWhatsApp,
    message: adminInquiryMessage(topic: topic, weddingDate: date),
  );
}
