import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:culinect/widgets/post_card.dart';
import 'package:flutter/material.dart';

class PostsTab extends StatelessWidget {
  final String userId;

  const PostsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('author.userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading posts'));
        }
        final posts = snapshot.data?.docs
            .map((doc) =>
                Posts.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (posts == null || posts.isEmpty) {
          return const Center(child: Text('No posts available'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(post: post, userId: userId);
          },
        );
      },
    );
  }
}
