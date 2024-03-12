import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/models/recipes/recipe.dart';
import 'package:culinect/screens/single/recipe_detail_screen.dart';
import 'package:flutter/material.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({Key? key}) : super(key: key);

  @override
  _RecipeFeedScreenState createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Recipe>> _recipeStream;

  @override
  void initState() {
    super.initState();
    _recipeStream = _fetchRecipes();
  }

  Stream<List<Recipe>> _fetchRecipes() {
    return _firestore.collection('recipes').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
                Recipe.fromMap(doc.data() as Map<String, dynamic>)..id = doc.id)
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Feed',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _recipeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes available.'));
          } else {
            final recipes = snapshot.data!;

            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: recipe.recipeImageUrl != null
                        ? Image.network(
                            recipe.recipeImageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.restaurant_menu, size: 80),
                    title: Text(
                      recipe.title ?? 'No Title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      recipe.description ?? 'No Description',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
