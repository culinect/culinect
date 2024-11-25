import 'package:flutter/material.dart';

class SpecialtySelector extends StatelessWidget {
  final List<String> selectedSpecialties;
  final Function(List<String>) onSpecialtiesChanged;

  final List<String> specialties = [
    'French Cuisine',
    'Italian Cuisine',
    'Asian Fusion',
    'Mediterranean',
    'Pastry & Baking',
    'Molecular Gastronomy',
    'Farm to Table',
    'Vegetarian/Vegan',
    'Seafood',
    'Butchery',
    'Wine Pairing',
    'Restaurant Management',
  ];

  SpecialtySelector({
    Key? key,
    required this.selectedSpecialties,
    required this.onSpecialtiesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: specialties.map((specialty) {
        final isSelected = selectedSpecialties.contains(specialty);
        return FilterChip(
          selected: isSelected,
          label: Text(specialty),
          onSelected: (selected) {
            final updatedSpecialties = List<String>.from(selectedSpecialties);
            if (selected) {
              updatedSpecialties.add(specialty);
            } else {
              updatedSpecialties.remove(specialty);
            }
            onSpecialtiesChanged(updatedSpecialties);
          },
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      }).toList(),
    );
  }
}
