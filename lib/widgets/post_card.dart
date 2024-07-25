import 'package:cached_network_image/cached_network_image.dart';
import 'package:culinect/models/posts/posts.dart';
import 'package:flutter/material.dart';

import '../screens/post_feed_screen.dart';

class PostCard extends StatelessWidget {
  final Posts post;
  final String userId;

  const PostCard({
    Key? key,
    required this.post,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorBasicInfo.fullName,
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
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16.0),
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
            if (post.location.isNotEmpty)
              Text(
                'Location: ${post.location}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
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
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () async {
                              await post.likePost(userId);
                              // Call setState to refresh the UI
                            },
                          );
                        } else if (snapshot.hasError) {
                          return IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: () {},
                          );
                        } else {
                          bool isLiked = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                            ),
                            onPressed: () async {
                              await post.likePost(userId);
                              // Call setState to refresh the UI
                            },
                          );
                        }
                      },
                    ),
                    Text('${post.likesCount}'),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return CommentsSheet(post: post, userId: userId);
                          },
                        );
                      },
                    ),
                    Text('${post.commentsCount}'),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
