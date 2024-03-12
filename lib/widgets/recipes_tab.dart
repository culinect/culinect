import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/models/recipes/recipe.dart';
import 'package:flutter/material.dart';

class RecipesTab extends StatelessWidget {
  final String userId;

  const RecipesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('author', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading recipes'));
        }
        final recipes = snapshot.data!.docs
            .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              title: Text(recipe.title ?? ''),
              subtitle: Text(recipe.description ?? ''),
            );
          },
        );
      },
    );
  }
}
