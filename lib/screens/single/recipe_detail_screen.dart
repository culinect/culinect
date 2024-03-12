import 'package:culinect/models/recipes/recipe.dart';
import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title ?? 'Recipe Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.recipeImageUrl != null)
              Image.network(recipe.recipeImageUrl!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipe.title ?? 'No Title',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                recipe.description ?? 'No Description',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cuisine: ${recipe.cuisine ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Course: ${recipe.course ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Preparation Time: ${recipe.prepTime ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cooking Time: ${recipe.cookTime ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Calories: ${recipe.calories ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Number of Servings: ${recipe.numServings ?? 'Not specified'}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipe.ingredientTitle ?? 'Ingredients',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (recipe.ingredients != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: recipe.ingredients!.map((ingredient) {
                    return Text(
                      '${ingredient['name']} - ${ingredient['quantity']}',
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                recipe.instructionSectionTitle ?? 'Instructions',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                recipe.instruction ?? 'No Instructions',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (recipe.instructionImage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(recipe.instructionImage!),
              ),
          ],
        ),
      ),
    );
  }
}
