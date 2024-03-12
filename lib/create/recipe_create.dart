import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:culinect/core/handlers/image_uploader/RecipeImageUploader.dart';
import 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderIo.dart'
if (dart.library.io) 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderIo.dart';
import 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderHtml.dart'
if (dart.library.html) 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderHtml.dart';
import 'package:culinect/theme/theme.dart';
import '../models/recipes/recipe.dart';
import 'package:culinect/core/recipe_provider.dart';

final RecipeImageUploader imageUploader = kIsWeb
? RecipeImageUploaderHtml()
    : RecipeImageUploaderIo();

class RecipeCreateScreen extends StatefulWidget {
const RecipeCreateScreen({super.key});

@override
_RecipeCreateScreenState createState() => _RecipeCreateScreenState();
}

class _RecipeCreateScreenState extends State<RecipeCreateScreen> {
  late final RecipeProvider _recipeProvider = RecipeProvider();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _recipeImage;
  bool _isLoading = false;

final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _cuisineController = TextEditingController();
final TextEditingController _courseController = TextEditingController();
final TextEditingController _keysController = TextEditingController();
final TextEditingController _badgesController = TextEditingController();
final TextEditingController _prepTimeController = TextEditingController();
final TextEditingController _cookTimeController = TextEditingController();
final TextEditingController _caloriesController = TextEditingController();
final TextEditingController _numServingsController = TextEditingController();
final TextEditingController _ingredientTitleController = TextEditingController();

final List<TextEditingController> _ingredientControllers = [];
final List<TextEditingController> _quantityControllers = [];
final List<TextEditingController> _unitControllers = [];
final List<TextEditingController> _remarksControllers = [];

final TextEditingController _instructionSectionTitleController =
TextEditingController();
final TextEditingController _instructionImageController =
TextEditingController();
final TextEditingController _instructionController = TextEditingController();

late final FirebaseAuth _auth;
late final FirebaseStorage _storage;

@override
void initState() {
super.initState();
_auth = FirebaseAuth.instance;
_storage = FirebaseStorage.instance;
_addIngredientField();
}

void _addIngredientField() {
_ingredientControllers.add(TextEditingController());
_quantityControllers.add(TextEditingController());
_unitControllers.add(TextEditingController());
_remarksControllers.add(TextEditingController());
setState(() {});
}

void _pickImage() async {
try {
final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
if (pickedImage != null) {
setState(() {
_recipeImage = pickedImage;
});
}
} catch (error) {
if (kDebugMode) {
  print('Error picking image: $error');
}
}
}

Future<String?> _uploadImage(String userId) async {
try {
if (_recipeImage != null) {
String imageUrl = await imageUploader.uploadImageToFirebase(_recipeImage!.path);
if (imageUrl.isNotEmpty) {
return imageUrl;
} else {
if (kDebugMode) {
  print('Empty URL obtained after image upload');
}
}
}
} catch (error) {
if (kDebugMode) {
  print('Error uploading image: $error');
}
}
return null;
}

Future<String?> _uploadVideo(String userId) async {
try {
if (_recipeImage != null) {
Reference ref = _storage.ref().child('recipes/$userId/video.mp4');
UploadTask uploadTask = ref.putFile(_recipeImage! as File);
TaskSnapshot snapshot = await uploadTask.whenComplete(() => print('Recipe image uploaded'));
return await snapshot.ref.getDownloadURL();
}
} catch (error) {
if (kDebugMode) {
  print('Error uploading Video: $error');
}
}
return null;
}
void _submitRecipe() async {
if (_formKey.currentState!.validate()) {
setState(() {
_isLoading = true;
});
try {
User? currentUser = _auth.currentUser;
if (currentUser != null) {
String userId = currentUser.uid;
String authorImage = 'url_to_author_image';
String authorName = 'author_name';

final String title = _titleController.text.trim();
final String description = _descriptionController.text.trim();
final String cuisine = _cuisineController.text.trim();
final String course = _courseController.text.trim();
final String keys = _keysController.text.trim();
final String badges = _badgesController.text.trim();
final String prepTime = _prepTimeController.text.isNotEmpty
? _prepTimeController.text
    : 'N/A';
final String cookTime = _cookTimeController.text.isNotEmpty
? _cookTimeController.text
    : 'N/A';
final String calories = _caloriesController.text.isNotEmpty
? _caloriesController.text
    : 'N/A';
final String numServings = _numServingsController.text.isNotEmpty
? _numServingsController.text
    : 'N/A';
final String ingredientTitle = _ingredientTitleController.text.isNotEmpty
? _ingredientTitleController.text
    : 'N/A';

List<Map<String, String>> ingredientsList = [];
for (int i = 0; i < _ingredientControllers.length; i++) {
String ingredient = _ingredientControllers[i].text;
String quantity = _quantityControllers[i].text;
String unit = _unitControllers[i].text;
String remarks = _remarksControllers[i].text;
if (ingredient.isNotEmpty && quantity.isNotEmpty) {
Map<String, String> ingredientMap = {
'ingredient': ingredient,
'quantity': quantity,
'unit': unit,
'remarks': remarks,
};
ingredientsList.add(ingredientMap);
}
}

String recipeImageUrl = '';
if (_recipeImage != null) {
recipeImageUrl = await imageUploader.uploadImageToFirebase(_recipeImage!.path);
}

final Map<String, dynamic> newRecipe = {
'author': userId,
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
'recipeImageUrl': recipeImageUrl,
'ingredients': ingredientsList,
};

Recipe recipe = Recipe.fromMap(newRecipe);
await _recipeProvider.addRecipe(recipe);
Navigator.of(context).pop();
} else {
if (kDebugMode) {
  print('No user is currently logged in');
}
}
} catch (error) {
if (kDebugMode) {
  print('Error: $error');
}
} finally {
setState(() {
_isLoading = false;
});
}
}
}

@override
void dispose() {
// Dispose controllers when the widget is disposed to avoid memory leaks
_titleController.dispose();
_descriptionController.dispose();
_cuisineController.dispose();
_courseController.dispose();
_keysController.dispose();
_badgesController.dispose();
_prepTimeController.dispose();
_cookTimeController.dispose();
_caloriesController.dispose();
_numServingsController.dispose();
_ingredientTitleController.dispose();
for (var controller in _ingredientControllers) {
controller.dispose();
}
for (var controller in _quantityControllers) {
controller.dispose();
}
for (var controller in _unitControllers) {
controller.dispose();
}
for (var controller in _remarksControllers) {
controller.dispose();
}
_instructionSectionTitleController.dispose();
_instructionImageController.dispose();
_instructionController.dispose();
if (kDebugMode) {
  print('Disposed');
}
super.dispose();
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Create Recipe'),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Form(
key: _formKey,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Recipe Details Section
const Text(
'Recipe Details:',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
TextFormField(
controller: _titleController,
decoration: const InputDecoration(labelText: 'Recipe Title'),
),
TextFormField(
controller: _descriptionController,
decoration: const InputDecoration(labelText: 'Short Description'),
),
TextFormField(
controller: _cuisineController,
decoration: const InputDecoration(labelText: 'Cuisine'),
),
TextFormField(
controller: _courseController,
decoration: const InputDecoration(labelText: 'Course'),
),
TextFormField(
controller: _keysController,
decoration: const InputDecoration(labelText: 'Recipe Keys'),
),
TextFormField(
controller: _badgesController,
decoration: const InputDecoration(labelText: 'Recipe Badges'),
),
const Divider(),
// Additional fields for Preptime, Cooktime, and Calories
TextFormField(
controller: _prepTimeController,
decoration: const InputDecoration(labelText: 'Prep Time'),
),
TextFormField(
controller: _cookTimeController,
decoration: const InputDecoration(labelText: 'Cook Time'),
),
TextFormField(
controller: _caloriesController,
decoration: const InputDecoration(labelText: 'Calories'),
),
const Divider(),
// Ingredients Section
const Text(
'Ingredients:',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
TextFormField(
controller: _numServingsController,
decoration: const InputDecoration(labelText: 'Number of Servings'),
),
TextFormField(
controller: _ingredientTitleController,
decoration: const InputDecoration(labelText: 'Ingredient Section Title'),
),
ListView.builder(
shrinkWrap: true,
itemCount: _ingredientControllers.length,
itemBuilder: (context, index) {
return Row(
children: [
Expanded(
child: TextFormField(
controller: _ingredientControllers[index],
decoration: const InputDecoration(labelText: 'Ingredient'),
),
),
Expanded(
child: TextFormField(
controller: _quantityControllers[index],
decoration: const InputDecoration(labelText: 'Quantity'),
),
),
Expanded(
child: TextFormField(
controller: _unitControllers[index],
decoration: const InputDecoration(labelText: 'Unit'),
),
),
Expanded(
child: TextFormField(
controller: _remarksControllers[index],
decoration: const InputDecoration(labelText: 'Remarks'),
),
),
],
);
},
),
ElevatedButton(
onPressed: _addIngredientField,
child: const Text('Add Ingredient Field'),
),
const Divider(),
// Instruction Section
const Text(
'Instruction:',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
TextFormField(
controller: _instructionSectionTitleController,
decoration: const InputDecoration(labelText: 'Instruction Section Title'),
),
TextFormField(
controller: _instructionImageController,
decoration: const InputDecoration(labelText: 'Instruction Image'),
),
TextFormField(
controller: _instructionController,
decoration: const InputDecoration(labelText: 'Instruction'),
maxLines: 5,
),
const Divider(),
// Add Video Section
ElevatedButton(
onPressed: _pickImage,
child: const Text('Add Image'),
),
const SizedBox(height: 20),
// Submit Button
ElevatedButton(
onPressed: _submitRecipe,
child: _isLoading
? const CircularProgressIndicator()
    : const Text('Submit Recipe'),
),
],
),
),
),
);
}
}


