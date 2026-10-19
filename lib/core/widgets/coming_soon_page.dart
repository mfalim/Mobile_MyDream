import 'package:flutter/material.dart';

/// Placeholder sementara untuk layar yang belum dibuat.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Segera hadir')),
    );
  }
}
