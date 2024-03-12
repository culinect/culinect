import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart'
    if (dart.library.html) 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart'
    if (dart.library.io) 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart';
import 'package:culinect/deep_linking/branch_link_generator.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles;

  Future<void> _pickImage() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null && selectedImages.length <= 5) {
      setState(() {
        _imageFiles = selectedImages;
      });
    } else {
      // Show an error message
    }
  }

  Future<void> _addPost() async {
    final postText = _postController.text.trim();
    if (postText.isNotEmpty && _imageFiles != null) {
      final List<String> imageUrls = [];

      for (XFile imageFile in _imageFiles!) {
        final imageUrl =
            await imageUploader.uploadImageToFirebase(imageFile.path);
        imageUrls.add(imageUrl);
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        final userData = await userRef.get();
        if (userData.exists) {
          final username =
              userData['username'] ?? ''; // Fetch the username from Firestore
          final email =
              userData['email'] ?? ''; // Fetch the email from Firestore
          final phoneNumber = userData['phoneNumber'] ??
              ''; // Fetch the phone number from Firestore
          final profilePicture = userData['profilePicture'] ??
              ''; // Fetch the profile picture URL from Firestore

          final newPost = Posts(
            postId: '', // Firestore will automatically generate this ID
            authorBasicInfo: UserBasicInfo(
              uid: currentUser.uid,
              fullName: username,
              email: email,
              phoneNumber: phoneNumber,
              profilePicture: profilePicture,
              profileLink: '',
              role: '', // Set the user's role
            ),
            content: postText,
            imageUrls: imageUrls,
            videoUrl: '', // If any video URL is added
            createdAt: Timestamp.now(),
            likesCount: 0,
            commentsCount: 0,
            savedCount: 0,
            postLink: '', // Set the post link
            location: '', // If any location is added
            analytics: {}, // If any analytics are added
            visibility: 'public', // Set visibility (public, private, etc.)
            reactions: {}, // If any reactions are added
          );

          try {
            final postRef = await FirebaseFirestore.instance
                .collection('posts')
                .add(newPost.toMap());
            final postId = postRef.id; // Get the auto-generated document ID
            String postLink = await BranchLinkGenerator.generatePostLink(
                postId, postText, imageUrls[0]);
            await postRef.update({
              'postId': postId,
              'postLink': postLink
            }); // Update the postId and postLink
            Navigator.of(context).pop();
          } catch (e) {
            print('Error adding post: $e');
          }
        } else {
          print('User data does not exist in Firestore');
        }
      }
    }
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
              title: const Text(
                'Create Post',
                style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                TextButton(
                  onPressed: _addPost,
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(snapshot.data![
                            'profilePicture']), // Current user's profile picture
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!['fullName'],
                            style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${snapshot.data!['username']}',
                            style: TextStyle(
                              fontFamily: 'NunitoSans',
                              fontSize: 14.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _postController,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontSize: 16,
                          color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    maxLines: 4,
                    style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text(
                      'Select from Device',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NunitoSans',
                          fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_imageFiles != null)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _imageFiles!.length,
                      itemBuilder: (context, index) {
                        if (kIsWeb) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              _imageFiles![index].path,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.file(
                              File(_imageFiles![index].path),
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data() as Map<String, dynamic>;
  }
}
