import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/config/config.dart';
import 'package:culinect/deep_linking/branch_link_generator.dart';
import 'package:culinect/deep_linking/branch_service.dart';
import 'package:culinect/home/home_screen.dart';
import 'package:culinect/onboarding/onboarding_flow.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final branchService = BranchService();

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> createUserInD1(AppUser appUser) async {
    final url = Uri.parse(
        'https://culinect-worker.culinect.workers.dev/api/create_user');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'uid': appUser.basicInfo.uid,
      'full_name': appUser.basicInfo.fullName,
      'email': appUser.basicInfo.email,
      'phone_number': appUser.basicInfo.phoneNumber,
      'profile_picture': appUser.basicInfo.profilePicture,
      'profile_link': appUser.basicInfo.profileLink,
      'role': appUser.basicInfo.role,
      'bio': appUser.extendedInfo.bio,
      'joined_at': appUser.extendedInfo.joinedAt.toIso8601String(),
      'resume_id': appUser.extendedInfo.resumeId,
      'post_count': appUser.extendedInfo.postCount,
      'recipe_count': appUser.extendedInfo.recipeCount,
      'jobs_count': appUser.extendedInfo.jobsCount,
      'username': appUser.extendedInfo.username,
      'followers_count': appUser.extendedInfo.followersCount,
      'following_count': appUser.extendedInfo.followingCount,
      'saved_posts': jsonEncode(appUser.extendedInfo.savedPosts),
      'post_links': jsonEncode(appUser.extendedInfo.postLinks),
      'is_profile_complete': false,
      'specialties': [],
      'interests': [],
      'professional_title': '',
      'years_experience': 0,
      'certifications': [],
      'education': []
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to create user in D1: ${response.body}');
    }

    final responseBody = response.body;
    if (responseBody != "User created successfully") {
      throw Exception('Failed to create user in D1: $responseBody');
    }
  }

  Future<void> _storeTokenInFirestore(String userId, String token) async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final userDoc = userCollection.doc(userId);

    await userDoc.update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> _initializeFCMToken(String userId) async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission();
      String? token = await messaging.getToken();
      if (token != null) {
        await _storeTokenInFirestore(userId, token);
      }

      messaging.onTokenRefresh.listen((newToken) async {
        await _storeTokenInFirestore(userId, newToken);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing FCM token: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive(
              backgroundColor: Colors.amberAccent, strokeWidth: 4.0);
        }

        final User? user = snapshot.data;
        if (user == null) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: GOOGLE_CLIENT_ID),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/culinect_logo.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to CuliNect, please sign in!')
                    : const Text('Welcome to CuliNect, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/images/culinect_logo.png'),
                ),
              );
            },
          );
        }

        final userCollection = FirebaseFirestore.instance.collection('users');
        final userDoc = userCollection.doc(user.uid);

        return FutureBuilder<DocumentSnapshot>(
          future: userDoc.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.purpleAccent,
                    strokeWidth: 4.0,
                  ),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final isProfileComplete = userData['isProfileComplete'] ?? false;

              _initializeFCMToken(user.uid);
              return isProfileComplete ? const HomeScreen() : OnboardingFlow();
            }

            return FutureBuilder<String>(
              future: BranchLinkGenerator.generateUserLink(
                user.uid,
                user.displayName ?? '',
                user.photoURL ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.purpleAccent,
                    strokeWidth: 4.0,
                  );
                }

                if (snapshot.hasData) {
                  String link = snapshot.data!;
                  AppUser appUser = AppUser(
                    basicInfo: UserBasicInfo(
                      uid: user.uid,
                      fullName: user.displayName ?? '',
                      email: user.email ?? '',
                      phoneNumber: user.phoneNumber ?? '',
                      profilePicture: user.photoURL ?? '',
                      profileLink: link,
                      role: '',
                    ),
                    extendedInfo: UserExtendedInfo(
                      bio: '',
                      joinedAt: DateTime.now(),
                      resumeId: '',
                      postCount: 0,
                      recipeCount: 0,
                      jobsCount: 0,
                      username: '',
                      followersCount: 0,
                      followingCount: 0,
                      savedPosts: [],
                      postLinks: {},
                    ),
                    fcmTokens: [],
                  );

                  userDoc.set(appUser.toMap()).then((_) async {
                    try {
                      await createUserInD1(appUser);
                      await _initializeFCMToken(user.uid);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnboardingFlow()),
                      );
                    } catch (e) {
                      if (kDebugMode) {
                        print('Error creating user in D1: $e');
                      }
                    }
                  });
                  return const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}
