import 'package:intl/intl.dart';

import '../../auth/models/app_user.dart';
import '../../imports.dart';

class Posts {
  final String postId;
  final UserBasicInfo authorBasicInfo;
  final String content;
  final List<String> imageUrls;
  final String videoUrl;
  final Timestamp createdAt;
  int likesCount;
  int commentsCount;
  int savedCount;
  String postLink;
  String location;
  Map<String, dynamic> analytics;
  String visibility;
  Map<String, int> reactions;

  Posts({
    required this.postId,
    required this.authorBasicInfo,
    required this.content,
    required this.imageUrls,
    required this.videoUrl,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.savedCount,
    required this.postLink,
    required this.location,
    required this.analytics,
    required this.visibility,
    required this.reactions,
  });

  factory Posts.fromMap(Map<String, dynamic> data, String postId) {
    // if (kDebugMode) {
    // print('Data from Firestore: $data');
    //} // Debug statement
    return Posts(
      postId: postId,
      authorBasicInfo: UserBasicInfo(
        uid: data['author']?['userId'] ?? '',
        fullName: data['author']?['fullName'] ?? '',
        email:
            '', // Add appropriate fields or use defaults based on your structure
        phoneNumber:
            '', // Add appropriate fields or use defaults based on your structure
        profilePicture: data['author']?['profilePicture'] ?? '',
        profileLink:
            '', // Add appropriate fields or use defaults based on your structure
        role: data['author']?['role'] ??
            '', // Set a default role or handle this based on your logic
      ),
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrl: data['videoUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      savedCount: data['savedCount'] ?? 0,
      postLink: data['postLink'] ?? '',
      location: data['location'] ?? '',
      analytics: Map<String, dynamic>.from(data['analytics'] ?? {}),
      visibility: data['visibility'] ?? 'public',
      reactions: Map<String, int>.from(data['reactions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': {
        'userId': authorBasicInfo.uid,
        'fullName': authorBasicInfo.fullName,
        'profilePicture': authorBasicInfo.profilePicture,
      },
      'content': content,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'savedCount': savedCount,
      'postLink': postLink,
      'location': location,
      'analytics': analytics,
      'visibility': visibility,
      'reactions': reactions,
    };
  }

  String getCreatedTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt.toDate());

    if (difference.inDays > 7) {
      return DateFormat.yMMMd().format(createdAt.toDate());
    } else if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days${days == 1 ? ' day' : ' days'} ago';
    } else if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours${hours == 1 ? ' hour' : ' hours'} ago';
    } else if (difference.inMinutes >= 1) {
      final minutes = difference.inMinutes;
      return '$minutes${minutes == 1 ? ' minute' : ' minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> likePost(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }

      await docRef.update({
        'likes': likes,
        'likesCount': likes.length,
      });
    }
  }

  Future<bool> isLikedByUser(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);
      return likes.contains(userId);
    }

    return false;
  }

  Future<List<DocumentSnapshot>> getComments() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs;
  }

  Future<void> addComment(String userId, String comment) async {
    final docRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    await docRef.collection('comments').add({
      'userId': userId,
      'comment': comment,
      'timestamp': Timestamp.now(),
    });

    await docRef.update({
      'commentsCount': FieldValue.increment(1),
    });
  }
}
