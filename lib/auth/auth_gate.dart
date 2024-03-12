import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider, EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinect/auth/models/app_user.dart';
import 'package:culinect/home.dart';
import 'package:culinect/config/config.dart';
import 'package:culinect/deep_linking/branch_service.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:culinect/deep_linking/branch_link_generator.dart';


final branchService = BranchService();
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive(backgroundColor: Colors.amberAccent,strokeWidth: 4.0);
        } else {
          final User? user = snapshot.data;
          if (user == null) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
//                PhoneAuthProvider(),
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
          } else {
            // User is signed in
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
                } else {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    // User document already exists
                    return const HomeScreen();
                  } else {
                    // User document does not exist, create and add to Firestore
                    final String userId = user.uid;
                    final String displayName = user.displayName ?? '';
                    final String photoUrl = user.photoURL ?? '';

                    // Generate user profile link
                    generateUserProfileLink(String userId, String displayName, String photoUrl) async {
                      String link = await BranchLinkGenerator.generateUserLink(userId, displayName, photoUrl);
                      return link;
                    }

                    return FutureBuilder<String>(
                      future: generateUserProfileLink(userId, displayName, photoUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator.adaptive(backgroundColor: Colors.purpleAccent,strokeWidth: 4.0);
                        } else {
                          if (snapshot.hasData) {
                            String link = snapshot.data!;
                            AppUser appUser = AppUser(
                              basicInfo: UserBasicInfo(
                                uid: user.uid,
                                fullName: displayName,
                                email: user.email ?? '',
                                phoneNumber: user.phoneNumber ?? '',
                                profilePicture: photoUrl,
                                profileLink: link,
                                role: '', // Add your logic to get role
                              ),
                              extendedInfo: UserExtendedInfo(
                                bio: '',
                                // Add your logic to get bio
                                joinedAt: DateTime.now(),
                                resumeId: '',
                                // Add your logic to get resumeId
                                postCount: 0,
                                recipeCount: 0,
                                jobsCount: 0,
                                username: '',
                                // Add your logic to get username
                                followersCount: 0,
                                followingCount: 0,
                                savedPosts: [],
                                // Initialize as empty list
                                postLinks: {}, // Initialize as empty map
                              ),
                            );

                            userDoc.set(appUser.toMap()).then((_) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const HomeScreen()),
                              );
                            }).catchError((error) {
                              // Handle the error appropriately
                              if (kDebugMode) {
                                print('Error setting user document: $error');
                              }

                            });
                            return const SizedBox.shrink(); // Return an empty widget
                          } else {
                            if (kDebugMode) {
                              print('Short URL generation failed');
                            }
                            return const SizedBox.shrink(); // Return an empty widget
                          }
                        }
                      },
                    );
                  }
                }
              },
            );
          }
        }
      },
    );
  }
}