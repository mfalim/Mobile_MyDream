import 'package:flutter/material.dart';

/// Server mengirim kunci teks untuk ikon; aplikasi yang memetakannya.
/// Kunci yang tidak dikenal memakai ikon bintang.
const _icons = <String, IconData>{
  'groups': Icons.groups_outlined,
  'sun': Icons.wb_sunny_outlined,
  'ceremony': Icons.celebration_outlined,
  'restaurant': Icons.restaurant,
  'bed': Icons.bed_outlined,
  'flower': Icons.local_florist_outlined,
  'sparkle': Icons.auto_awesome_outlined,
  'camera': Icons.photo_camera_outlined,
  'video': Icons.videocam_outlined,
  'brush': Icons.brush_outlined,
  'verified': Icons.verified_outlined,
  'event': Icons.event_note_outlined,
  'drone': Icons.flight,
  'dress': Icons.checkroom_outlined,
  'check': Icons.check_circle_outline,
  'palette': Icons.palette_outlined,
  'music': Icons.music_note,
};

IconData iconFor(String key) => _icons[key] ?? Icons.star_outline;
