import 'package:flutter/material.dart';

/// Baris kartu yang bisa digeser ke samping. Tingginya mengikuti kartu
/// tertinggi, jadi aman untuk ukuran teks besar.
class HorizontalCardList extends StatelessWidget {
  const HorizontalCardList({required this.children, this.gap = 12, super.key});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++)
            Padding(
              padding:
                  EdgeInsets.only(right: i == children.length - 1 ? 0 : gap),
              child: children[i],
            ),
        ],
      ),
    );
  }
}
