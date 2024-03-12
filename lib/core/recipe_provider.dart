import 'package:culinect/models/recipes/recipe.dart';

import '../imports.dart';

class RecipeProvider with ChangeNotifier {
  final CollectionReference _recipesCollection =
  FirebaseFirestore.instance.collection('recipes');

  List<Recipe?> _recipes = [];

  List<Recipe?> get recipes {
    return [..._recipes];
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _recipesCollection.add(recipe.toMap());
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error adding recipe: $error');
      }
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _recipesCollection.doc((recipe.id)).update(recipe.toMap());
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error updating recipe: $error');
      }
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _recipesCollection.doc(recipeId).delete();
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting recipe: $error');
      }
    }
  }

  Future<void> fetchRecipes() async {
    try {
      QuerySnapshot recipesSnapshot = await _recipesCollection.get();
      _recipes = recipesSnapshot.docs.map((doc) {
        Object? data = doc.data();
        if (data != null) {
          Map<String, dynamic> map = data as Map<String, dynamic>;
          if (map.containsKey('id') &&
              map.containsKey('author') &&
              map.containsKey('authorImage') &&
              map.containsKey('authorName') &&
              map.containsKey('title') &&
              map.containsKey('description') &&
              map.containsKey('cuisine') &&
              map.containsKey('course') &&
              map.containsKey('keys') &&
              map.containsKey('badges') &&
              map.containsKey('prepTime') &&
              map.containsKey('cookTime') &&
              map.containsKey('calories') &&
              map.containsKey('numServings') &&
              map.containsKey('ingredientTitle') &&
              map.containsKey('ingredients') &&
              map.containsKey('recipeImageUrl') &&
              map.containsKey('instructionSectionTitle') &&
              map.containsKey('instructionImage') &&
              map.containsKey('instruction')) {
            return Recipe.fromMap(map);
          } else {
            return null;
          }
        } else {
          return null;
        }
      }).where((recipe) => recipe != null).toList();
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching recipes: $error');
      }
    }
  }
}
