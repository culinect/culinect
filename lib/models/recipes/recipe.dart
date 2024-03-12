class Recipe {
  String? id;
  String? author;
  String? authorImage;
  String? authorName;
  String? title;
  String? description;
  String? cuisine;
  String? course;
  String? keys;
  String? badges;
  String? prepTime;
  String? cookTime;
  String? calories;
  String? numServings;
  String? ingredientTitle;
  List<Map<String, String>>? ingredients;
  String? recipeImageUrl;
  String? instructionSectionTitle;
  String? instructionImage;
  String? instruction;

  Recipe({
    this.id,
    this.author,
    this.authorImage,
    this.authorName,
    this.title,
    this.description,
    this.cuisine,
    this.course,
    this.keys,
    this.badges,
    this.prepTime,
    this.cookTime,
    this.calories,
    this.numServings,
    this.ingredientTitle,
    this.ingredients,
    this.recipeImageUrl,
    this.instructionSectionTitle,
    this.instructionImage,
    this.instruction,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String?,
      author: map['author'] as String?,
      authorImage: map['authorImage'] as String?,
      authorName: map['authorName'] as String?,
      title: map['title'] as String?,
      description: map['description'] as String?,
      cuisine: map['cuisine'] as String?,
      course: map['course'] as String?,
      keys: map['keys'] as String?,
      badges: map['badges'] as String?,
      prepTime: map['prepTime'] as String?,
      cookTime: map['cookTime'] as String?,
      calories: map['calories'] as String?,
      numServings: map['numServings'] as String?,
      ingredientTitle: map['ingredientTitle'] as String?,
      ingredients: (map['ingredients'] as List<dynamic>?)
          ?.map((e) => Map<String, String>.from(e as Map))
          .toList(),
      recipeImageUrl: map['recipeImageUrl'] as String?,
      instructionSectionTitle: map['instructionSectionTitle'] as String?,
      instructionImage: map['instructionImage'] as String?,
      instruction: map['instruction'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'authorImage': authorImage,
      'authorName': authorName,
      'title': title,
      'description': description,
      'cuisine': cuisine,
      'course': course,
      'keys': keys,
      'badges': badges,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'calories': calories,
      'numServings': numServings,
      'ingredientTitle': ingredientTitle,
      'ingredients': ingredients,
      'recipeImageUrl': recipeImageUrl,
      'instructionSectionTitle': instructionSectionTitle,
      'instructionImage': instructionImage,
      'instruction': instruction,
    };
  }
}
