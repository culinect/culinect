import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/config/config.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart'
    if (dart.library.html) 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart'
    if (dart.library.io) 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart';
import 'package:culinect/deep_linking/branch_link_generator.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/models/app_user.dart';
import '../core/handlers/postimage_uploader/upload_image.dart';

final PostImageUploader imageUploader =
    kIsWeb ? ImageUploaderHtml() : ImageUploaderIo();

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _visibility = 'public';
  String _location = 'unknown';
  bool _isUploading = false;
  bool _isFetchingLocation = false;
  FlutterGooglePlacesSdk places = FlutterGooglePlacesSdk(GOOGLE_PLACES_API_KEY);
  List<AutocompletePrediction> _placePredictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _postController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selectedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _imageFile = selectedImage;
        });
      }
    } catch (e) {
      _showSnackbar('Error picking image: $e');
    }
  }

  Future<void> _addPost() async {
    final postText = _postController.text.trim();
    if (postText.isEmpty || _imageFile == null) {
      _showSnackbar('Please add an image and write a caption.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl =
          await imageUploader.uploadImageToFirebase(_imageFile!.path);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final userData = await userRef.get();

        if (userData.exists) {
          final username = userData['username'] ?? '';
          final fullName =
              userData['fullName'] ?? 'Unknown'; // Ensure fullName is retrieved
          final email = userData['email'] ?? '';
          final phoneNumber = userData['phoneNumber'] ?? '';
          final profilePicture = userData['profilePicture'] ?? '';

          final newPost = Posts(
            postId: '',
            authorBasicInfo: UserBasicInfo(
              uid: currentUser.uid,
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              profilePicture: profilePicture,
              profileLink: '',
              role: '',
            ),
            content: postText,
            imageUrls: [imageUrl],
            videoUrl: '',
            createdAt: Timestamp.now(),
            likesCount: 0,
            commentsCount: 0,
            savedCount: 0,
            postLink: '',
            location: _location,
            analytics: {},
            visibility: _visibility,
            reactions: {},
          );

          final postRef = await FirebaseFirestore.instance
              .collection('posts')
              .add(newPost.toMap());
          final postId = postRef.id;
          String postLink = await BranchLinkGenerator.generatePostLink(
              postId, postText, imageUrl);
          await postRef.update({'postId': postId, 'postLink': postLink});
          Navigator.of(context).pop();
        } else {
          _showSnackbar('User data does not exist in Firestore.');
        }
      } else {
        _showSnackbar('User is not logged in.');
      }
    } catch (e) {
      _showSnackbar('Error adding post: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _searchPlace(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final predictionsResponse =
            await places.findAutocompletePredictions(input);

        setState(() {
          _placePredictions = predictionsResponse.predictions;
        });
      } catch (e) {
        _showSnackbar('Error searching place: $e');
      }
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: const Text(
                'Create Post',
                style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              actions: [
                IconButton(
                  icon: _isUploading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check),
                  onPressed: _isUploading ? null : _addPost,
                ),
              ],
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(_imageFile!.path)
                                      : FileImage(File(_imageFile!.path))
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black45,
                                  size: 50,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _postController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Visibility',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButton<String>(
                      value: _visibility,
                      onChanged: (String? newValue) {
                        setState(() {
                          _visibility = newValue!;
                        });
                      },
                      items: <String>['public', 'followers', 'private']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Location',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _placeController,
                      onChanged: _searchPlace,
                      decoration: InputDecoration(
                        hintText: 'Search place...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _placePredictions.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _placePredictions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  _placePredictions[index].fullText ?? '',
                                ),
                                onTap: () {
                                  _placeController.text =
                                      _placePredictions[index].fullText ?? '';
                                  setState(() {
                                    _location =
                                        _placePredictions[index].fullText ?? '';
                                    _placePredictions = [];
                                  });
                                },
                              );
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final userData = await userRef.get();

      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      } else {
        throw Exception('User data does not exist in Firestore.');
      }
    } else {
      throw Exception('User is not logged in.');
    }
  }
}
