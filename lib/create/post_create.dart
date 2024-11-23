import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart'
    if (dart.library.html) 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart'
    if (dart.library.io) 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart';
import 'package:culinect/deep_linking/branch_link_generator.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
          final profileLink = userData['profileLink'] ?? '';
          final newPost = Posts(
            postId: '',
            authorBasicInfo: UserBasicInfo(
              uid: currentUser.uid,
              fullName: fullName,
              email: email,
              phoneNumber: phoneNumber,
              profilePicture: profilePicture,
              profileLink: profileLink,
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

          // Add post to Firestore
          final postRef = await FirebaseFirestore.instance
              .collection('posts')
              .add(newPost.toMap());
          final postId = postRef.id;
          String postLink = await BranchLinkGenerator.generatePostLink(
              postId, postText, imageUrl);
          await postRef.update({'postId': postId, 'postLink': postLink});

          // Create post in D1
          await createPostInD1(newPost, postId, postLink);

// After creating post, trigger notification
          /*  try {
            final response = await http.post(
              Uri.parse('https://notification-worker.culinect.workers.dev'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'type': 'post',
                'data': {
                  'userId': currentUser.uid,
                  'postId': postId,
                  'title': postText,
                  'content': postText,
                }
              }),
            );

            if (response.statusCode == 200) {
              if (kDebugMode) {
                print("Notification triggered successfully");
              }
              _showSnackbar(
                  'Post created and notification sent!'); // User feedback
            } else {
              // Log the response body to get more details on failure
              if (kDebugMode) {
                print("Failed to trigger notification: ${response.statusCode}");
              }
              if (kDebugMode) {
                print("Response body: ${response.body}");
              }
              _showSnackbar(
                  'Error sending notification. Please try again.'); // Error handling
            }
          } catch (error) {
            if (kDebugMode) {
              print("Error triggering notification: $error");
            }
            _showSnackbar(
                'Error sending notification. Please try again.'); // Error handling
          }*/

          // final notificationService =
          //   Provider.of<NotificationService>(context, listen: false);

          /* Creating a new notification instance
          final notification = InAppNotification(
            title: 'New Post!',
            body: 'A new post has been created.',
            timestamp: DateTime.now(),
            isRead: false, // Default to false since the notification is new
          );*/

          // Add the notification to Firestore and locally
          // await notificationService.addNotification(notification);

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

  void validatePayload(Map<String, dynamic> payload) {
    print('Post Payload: ${jsonEncode(payload)}');
  }

  Future<void> createPostInD1(
      Posts post, String postId, String postLink) async {
    final url = Uri.parse(
        'https://culinect-worker.culinect.workers.dev/api/create_post');
    final headers = {'Content-Type': 'application/json'};

    final body = {
      'post_id': postId,
      'author_uid': post.authorBasicInfo.uid,
      'fullName': post.authorBasicInfo.fullName,
      'profilePicture': post.authorBasicInfo.profilePicture,
      'profileLink': post.authorBasicInfo.profileLink,
      'content': post.content,
      'image_urls': jsonEncode(post.imageUrls),
      'video_url': post.videoUrl,
      'created_at': post.createdAt.toDate().toIso8601String(),
      'likes_count': post.likesCount,
      'comments_count': post.commentsCount,
      'saved_count': post.savedCount,
      'post_link': postLink,
      'location': post.location,
      'analytics': jsonEncode(post.analytics),
      'visibility': post.visibility,
      'reactions': jsonEncode(post.reactions),
    };

    validatePayload(body); // Validate before sending

    final response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode != 201) {
      throw Exception('Failed to create post in D1: ${response.body}');
    }

    final responseBody = response.body;
    if (responseBody != "Post created successfully") {
      throw Exception('Failed to create post in D1: $responseBody');
    }
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
                      decoration: const InputDecoration(
                        hintText: 'Write something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Add any additional fields or widgets here
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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data() ?? {};
    } else {
      return {};
    }
  }
}
