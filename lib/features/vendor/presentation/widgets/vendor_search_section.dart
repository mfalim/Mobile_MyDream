import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class VendorSearchSection extends StatefulWidget {
  const VendorSearchSection({super.key});

  @override
  State<VendorSearchSection> createState() => _VendorSearchSectionState();
}

class _VendorSearchSectionState extends State<VendorSearchSection> {
  String _category = 'Semua Kategori';
  String _location = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cari vendor berdasarkan:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _filter(
              'Kategori',
              _category,
              const [
                'Semua Kategori',
                'Venue',
                'Fotografer',
                'MUA',
                'Catering'
              ],
              (value) => setState(() => _category = value)),
          const SizedBox(height: 9),
          _filter(
              'Lokasi',
              _location,
              const ['Indonesia', 'Yogyakarta', 'Jakarta', 'Bali'],
              (value) => setState(() => _location = value)),
          const SizedBox(height: 9),
          _filter(
              'Budget',
              'Semua Budget',
              const [
                'Semua Budget',
                'Di bawah Rp5 juta',
                'Rp5–20 juta',
                'Di atas Rp20 juta'
              ],
              (_) {}),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text('Cari Vendor'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filter(String label, String value, List<String> options,
      ValueChanged<String> onSelected) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: AppColors.line),
        ),
      ),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (selected) {
        if (selected != null) onSelected(selected);
      },
    );
  }
}
