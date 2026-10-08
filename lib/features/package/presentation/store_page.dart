import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String _selectedCategory = 'Semua';
  int _cartCount = 0;

  static const _products = [
    ('Undangan floral', 'Stationery', 'Rp25.000', Icons.mail_outline_rounded),
    ('Souvenir keramik', 'Hadiah', 'Rp38.000', Icons.card_giftcard_rounded),
    ('Buku tamu linen', 'Stationery', 'Rp85.000', Icons.menu_book_rounded),
    ('Kotak cincin kayu', 'Aksesori', 'Rp120.000', Icons.diamond_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final products = _selectedCategory == 'Semua'
        ? _products
        : _products.where((item) => item.$2 == _selectedCategory).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEDDING STORE',
                            style: TextStyle(
                                color: AppColors.coralDark,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2)),
                        SizedBox(height: 6),
                        Text('Detail kecil, makna besar',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Badge(
                    label: Text('$_cartCount'),
                    isLabelVisible: _cartCount > 0,
                    child: IconButton(
                      tooltip: 'Keranjang',
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_bag_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEE6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Made for your moment',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 17)),
                        SizedBox(height: 6),
                        Text('Temukan kebutuhan hari bahagiamu.',
                            style: TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Icon(Icons.redeem_rounded, size: 40, color: AppColors.sage),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: Row(
                children: [
                  for (final category in const [
                    'Semua',
                    'Stationery',
                    'Hadiah',
                    'Aksesori'
                  ]) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.83,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.blush,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(7)),
                          ),
                          child: Icon(product.$4,
                              color: AppColors.coralDark, size: 42),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 9, 8, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.$1,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text(product.$3,
                                      style: const TextStyle(
                                          color: AppColors.coralDark,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Tambah ke keranjang',
                              onPressed: () => setState(() => _cartCount++),
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.coralDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
