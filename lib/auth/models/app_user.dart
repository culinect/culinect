import 'package:cloud_firestore/cloud_firestore.dart';

class UserBasicInfo {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String profileLink;
  final String role;
  final String professionalTitle;
  final String currentWorkplace;
  final int yearsExperience;
  final List<String> specialties;
  final List<String> certifications;
  final List<String> education;

  UserBasicInfo({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.profileLink,
    required this.role,
    this.professionalTitle = '',
    this.currentWorkplace = '',
    this.yearsExperience = 0,
    this.specialties = const [],
    this.certifications = const [],
    this.education = const [],
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePicture': profilePicture,
        'profileLink': profileLink,
        'role': role,
        'professionalTitle': professionalTitle,
        'currentWorkplace': currentWorkplace,
        'yearsExperience': yearsExperience,
        'specialties': specialties,
        'certifications': certifications,
        'education': education,
      };

  factory UserBasicInfo.fromMap(Map<String, dynamic> map) => UserBasicInfo(
        uid: map['uid'] ?? '',
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        profilePicture: map['profilePicture'] ?? '',
        profileLink: map['profileLink'] ?? '',
        role: map['role'] ?? '',
        professionalTitle: map['professionalTitle'] ?? '',
        currentWorkplace: map['currentWorkplace'] ?? '',
        yearsExperience: map['yearsExperience'] ?? 0,
        specialties: List<String>.from(map['specialties'] ?? []),
        certifications: List<String>.from(map['certifications'] ?? []),
        education: List<String>.from(map['education'] ?? []),
      );

  UserBasicInfo copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? profileLink,
    String? role,
    String? professionalTitle,
    String? currentWorkplace,
    int? yearsExperience,
    List<String>? specialties,
    List<String>? certifications,
    List<String>? education,
  }) {
    return UserBasicInfo(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      profileLink: profileLink ?? this.profileLink,
      role: role ?? this.role,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      currentWorkplace: currentWorkplace ?? this.currentWorkplace,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      specialties: specialties ?? this.specialties,
      certifications: certifications ?? this.certifications,
      education: education ?? this.education,
    );
  }
}

class UserExtendedInfo {
  final String bio;
  final DateTime joinedAt;
  final String resumeId;
  final int postCount;
  final int recipeCount;
  final int jobsCount;
  final String username;
  final int followersCount;
  final int followingCount;
  final List<String> savedPosts;
  final Map<String, dynamic> postLinks;
  final List<String> interests;
  final bool isProfileComplete;

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
    this.interests = const [],
    this.isProfileComplete = false,
  });

  Map<String, dynamic> toMap() => {
        'bio': bio,
        'joinedAt': joinedAt,
        'resumeId': resumeId,
        'postCount': postCount,
        'recipeCount': recipeCount,
        'jobsCount': jobsCount,
        'username': username,
        'followersCount': followersCount,
        'followingCount': followingCount,
        'savedPosts': savedPosts,
        'postLinks': postLinks,
        'interests': interests,
        'isProfileComplete': isProfileComplete,
      };

  factory UserExtendedInfo.fromMap(Map<String, dynamic> map) =>
      UserExtendedInfo(
        bio: map['bio'] ?? '',
        joinedAt: (map['joinedAt'] as Timestamp).toDate(),
        resumeId: map['resumeId'] ?? '',
        postCount: map['postCount'] ?? 0,
        recipeCount: map['recipeCount'] ?? 0,
        jobsCount: map['jobsCount'] ?? 0,
        username: map['username'] ?? '',
        followersCount: map['followersCount'] ?? 0,
        followingCount: map['followingCount'] ?? 0,
        savedPosts: List<String>.from(map['savedPosts'] ?? []),
        postLinks: Map<String, dynamic>.from(map['postLinks'] ?? {}),
        interests: List<String>.from(map['interests'] ?? []),
        isProfileComplete: map['isProfileComplete'] ?? false,
      );

  UserExtendedInfo copyWith({
    String? bio,
    DateTime? joinedAt,
    String? resumeId,
    int? postCount,
    int? recipeCount,
    int? jobsCount,
    String? username,
    int? followersCount,
    int? followingCount,
    List<String>? savedPosts,
    Map<String, dynamic>? postLinks,
    List<String>? interests,
    bool? isProfileComplete,
  }) {
    return UserExtendedInfo(
      bio: bio ?? this.bio,
      joinedAt: joinedAt ?? this.joinedAt,
      resumeId: resumeId ?? this.resumeId,
      postCount: postCount ?? this.postCount,
      recipeCount: recipeCount ?? this.recipeCount,
      jobsCount: jobsCount ?? this.jobsCount,
      username: username ?? this.username,
      followersCount: followersCount ?? this.followingCount,
      followingCount: followingCount ?? this.followingCount,
      savedPosts: savedPosts ?? this.savedPosts,
      postLinks: postLinks ?? this.postLinks,
      interests: interests ?? this.interests,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class AppUser {
  final UserBasicInfo basicInfo;
  final UserExtendedInfo extendedInfo;
  final List<String> fcmTokens;

  AppUser({
    required this.basicInfo,
    required this.extendedInfo,
    required this.fcmTokens,
  });

  Map<String, dynamic> toMap() => {
        ...basicInfo.toMap(),
        ...extendedInfo.toMap(),
        'fcmTokens': fcmTokens,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        basicInfo: UserBasicInfo.fromMap(map),
        extendedInfo: UserExtendedInfo.fromMap(map),
        fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
      );

  AppUser copyWith({
    UserBasicInfo? basicInfo,
    UserExtendedInfo? extendedInfo,
    List<String>? fcmTokens,
  }) {
    return AppUser(
      basicInfo: basicInfo ?? this.basicInfo,
      extendedInfo: extendedInfo ?? this.extendedInfo,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
