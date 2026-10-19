import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class ConceptSelector extends StatelessWidget {
  const ConceptSelector({
    required this.concepts,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> concepts;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < concepts.length; i++)
          ChoiceChip(
            label: Text(concepts[i]),
            selected: i == selectedIndex,
            onSelected: (_) => onChanged(i),
            showCheckmark: true,
            checkmarkColor: Colors.white,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceTint,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: i == selectedIndex ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}
