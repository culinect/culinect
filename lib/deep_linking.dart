import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:culinect/user/UserProfile_Screen.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'main.dart';
import 'deep_linking/branch_service.dart'; // Import your branch_service.dart file

Future<String?> getInitialLink() async {
  try {
    final initialLink = await BranchService().initSession().first;
    return initialLink['~referring_link'];
  } catch (error) {
    print('Error getting initial link: $error');
    return null;
  }
}

Stream<String?> getLinksStream() {
  try {
    return BranchService().initSession().map((data) => data['~referring_link']);
  } catch (error) {
    print('Error getting link stream: $error');
    return const Stream<String?>.empty();
  }
}

void handleLink(String? link) {
  if (link != null) {
    try {
      Uri uri = Uri.parse(link);
      String path = uri.path;
      String id = uri.pathSegments.last;

      if (path.startsWith('/posts')) {
        if (kDebugMode) {
          print('Navigate to post: $id');
        }
      } else if (path.startsWith('/recipes')) {
        if (kDebugMode) {
          print('Navigate to recipe: $id');
        }
      } else if (path.startsWith('/jobs')) {
        if (kDebugMode) {
          print('Navigate to Job: $id');
        }
      } else if (path.startsWith('/users')) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => UserProfileScreen(userId: id)),
        );
        if (kDebugMode) {
          print('Navigate to member: $id');
        }
      } else if (path.startsWith('/resumes')) {
        if (kDebugMode) {
          print('Navigate to Resume: $id');
        }
      } else if (path.startsWith('/quiz')) {
        print('Navigate to Quiz: $id');
      }
    } catch (error) {
      print('Error handling deep link: $error');
    }
  }
}
