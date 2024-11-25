import 'package:flutter/material.dart';

class InterestGrid extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(List<String>) onInterestsChanged;

  final List<Map<String, dynamic>> interests = [
    {
      'title': 'Recipe Development',
      'icon': Icons.restaurant_menu,
    },
    {
      'title': 'Kitchen Management',
      'icon': Icons.business,
    },
    {
      'title': 'Food Photography',
      'icon': Icons.camera_alt,
    },
    {
      'title': 'Wine & Beverages',
      'icon': Icons.wine_bar,
    },
    {
      'title': 'Sustainable Cooking',
      'icon': Icons.eco,
    },
    {
      'title': 'Food Science',
      'icon': Icons.science,
    },
    {
      'title': 'Restaurant Tech',
      'icon': Icons.computer,
    },
    {
      'title': 'Food Safety',
      'icon': Icons.security,
    },
    {
      'title': 'Menu Planning',
      'icon': Icons.menu_book,
    },
    {
      'title': 'Food Culture',
      'icon': Icons.public,
    },
    {
      'title': 'Career Growth',
      'icon': Icons.trending_up,
    },
    {
      'title': 'Food Innovation',
      'icon': Icons.lightbulb,
    },
  ];

  InterestGrid({
    Key? key,
    required this.selectedInterests,
    required this.onInterestsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: interests.length,
      itemBuilder: (context, index) {
        final interest = interests[index];
        final isSelected = selectedInterests.contains(interest['title']);

        return InkWell(
          onTap: () {
            final updatedInterests = List<String>.from(selectedInterests);
            if (isSelected) {
              updatedInterests.remove(interest['title']);
            } else {
              updatedInterests.add(interest['title']);
            }
            onInterestsChanged(updatedInterests);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  interest['icon'],
                  size: 32,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                Text(
                  interest['title'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
