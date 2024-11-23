import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/posts/posts.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({Key? key}) : super(key: key);

  @override
  _PostFeedScreenState createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = 'currentUserId'; // Replace with actual user ID logic

  Future<List<Posts>> _getPosts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('posts').get();
      // print(          'Posts fetched from Firestore: ${querySnapshot.docs.length}'); // Debug statement
      return querySnapshot.docs.map((doc) {
        // print('Post data: ${doc.data()}'); // Debug statement
        return Posts.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error loading posts: $e'); // Log the error
      rethrow;
    }
  }

  Widget _buildPostCard(Posts post) {
    //print(        'Building post card for: ${post.authorBasicInfo.fullName}'); // Debug statement
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      NetworkImage(post.authorBasicInfo.profilePicture),
                  radius: 25.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorBasicInfo.fullName.isNotEmpty
                            ? post.authorBasicInfo.fullName
                            : 'Unknown', // Fallback to 'Unknown'
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        post.getCreatedTimeAgo(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            if (post.imageUrls.isNotEmpty)
              CachedNetworkImage(
                imageUrl: post.imageUrls[0],
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            const SizedBox(height: 10.0),
            Text(
              post.content,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    FutureBuilder<bool>(
                      future: post.isLikedByUser(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return IconButton(
                            icon: const Icon(FontAwesomeIcons.heart),
                            onPressed: () async {
                              await post.likePost(userId);
                              setState(() {});
                            },
                          );
                        } else if (snapshot.hasError) {
                          return IconButton(
                            icon: const Icon(FontAwesomeIcons.heart),
                            onPressed: () {},
                          );
                        } else {
                          bool isLiked = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              await post.likePost(userId);
                              setState(() {});
                            },
                          );
                        }
                      },
                    ),
                    Text('${post.likesCount}'),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.comment),
                      onPressed: () {
                        _showCommentsSheet(context, post);
                      },
                    ),
                    Text('${post.commentsCount}'),
                  ],
                ),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, Posts post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CommentsSheet(post: post, userId: userId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Posts>>(
        future: _getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error in FutureBuilder: ${snapshot.error}'); // Log the error
            return const Center(child: Text('Error loading posts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Posts post = snapshot.data![index];
                return _buildPostCard(post);
              },
            );
          }
        },
      ),
    );
  }
}

class CommentsSheet extends StatefulWidget {
  final Posts post;
  final String userId;

  const CommentsSheet({required this.post, required this.userId, Key? key})
      : super(key: key);

  @override
  _CommentsSheetState createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await widget.post.addComment(widget.userId, _commentController.text);
      _commentController.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 15.0,
        right: 15.0,
        top: 15.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: widget.post.getComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(
                      'Error in Comments FutureBuilder: ${snapshot.error}'); // Log the error
                  return const Center(child: Text('Error loading comments'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot comment = snapshot.data![index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/150'),
                        ),
                        title: Text(comment['comment']),
                        subtitle:
                            Text(comment['timestamp'].toDate().toString()),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addComment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
