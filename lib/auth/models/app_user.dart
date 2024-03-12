import 'package:cloud_firestore/cloud_firestore.dart';



class UserBasicInfo {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  late final String profilePicture;
  String profileLink;
  final String role; // Adding user role field

  UserBasicInfo({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.profileLink,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'profileLink': profileLink,
      'role': role, // Storing role as a string
    };
  }
}

class UserExtendedInfo {
  final String bio;
  final DateTime joinedAt;
  final String resumeId;
  int postCount;
  int recipeCount;
  int jobsCount;
  String username;
  int followersCount;
  int followingCount;
  List<String> savedPosts; // For saved posts by the user
  Map<String, dynamic> postLinks; // Link association for various post types

  UserExtendedInfo({
    required this.bio,
    required this.joinedAt,
    required this.resumeId,
    required this.postCount,
    required this.recipeCount,
    required this.jobsCount,
    required this.username,
    required this.followersCount,
    required this.followingCount,
    required this.savedPosts,
    required this.postLinks,
  });

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'resumeId': resumeId,
      'postCount': postCount,
      'recipeCount': recipeCount,
      'jobsCount': jobsCount,
      'username': username,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'savedPosts': savedPosts,
      'postLinks': postLinks,
    };
  }
}

class AppUser {
  final UserBasicInfo basicInfo;
  final UserExtendedInfo extendedInfo;

  AppUser({
    required this.basicInfo,
    required this.extendedInfo,
  });

  factory AppUser.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError('Data is null');
    }

    return AppUser(
      basicInfo: UserBasicInfo(
        uid: data['uid'] ?? '',
        fullName: data['fullName'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phoneNumber'] ?? '',
        profilePicture: data['profileImage'] ?? '',
        profileLink: data['profileLink'] ?? '',
        role: data['role'] ?? '',
      ),
      extendedInfo: UserExtendedInfo(
        bio: data['bio'] ?? '',
        joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        resumeId: data['resumeId'] ?? '',
        postCount: data['postCount'] ?? 0,
        recipeCount: data['recipeCount'] ?? 0,
        jobsCount: data['jobsCount'] ?? 0,
        username: data['username'] ?? '',
        followersCount: data['followersCount'] ?? 0,
        followingCount: data['followingCount'] ?? 0,
        savedPosts: List<String>.from(data['savedPosts'] ?? []),
        postLinks: Map<String, dynamic>.from(data['postLinks'] ?? {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...basicInfo.toMap(),
      ...extendedInfo.toMap(),
    };
  }
}
