import 'package:app_links/app_links.dart';
import 'package:culinect/user/UserProfile_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart' as FlutterBranchSdk;

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();

  static Future<String?> getInitialLink() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      return initialLink?.toString();
    } catch (error) {
      // Handle specific exceptions from app_links
      print('Error getting initial link: $error');
      return null;
    }
  }

  static Stream<String?> getLinksStream() {
    try {
      return _appLinks.uriLinkStream
          .map((event) => event?.toString())
          .handleError((error) {
        // Handle specific exceptions from app_links
        print('Error getting link stream: $error');
        return null;
      });
    } catch (error) {
      // Handle unexpected errors
      print('Error getting link stream: $error');
      return const Stream<String?>.empty();
    }
  }

  static void handleLink(BuildContext context, String? link) {
    if (link != null) {
      try {
        Uri uri = Uri.parse(link);
        String path = uri.path;
        String id = uri.pathSegments.last;

        if (path.startsWith('/users')) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: id)));
        } else {
          // Handle other paths using a builder function
          handleOtherPath(context, path, id);
        }
      } catch (error) {
        // Handle URI parsing errors
        print('Error parsing link: $error');
      }
    }
  }

  static void handleOtherPath(BuildContext context, String path, String id) {
    // Implement logic for handling other deep link paths
  }
}

class LinkGenerator {
  static const imageURL = 'assets/Culinect_logo.png';

  static Future<String?> generateShortUrl({
    required String userId,
    required String displayName,
    String? photoURL,
  }) async {
    final buo = FlutterBranchSdk.BranchUniversalObject(
      canonicalIdentifier: 'user/$userId',
      title: 'Profile: $displayName',
      contentDescription: 'Check out $displayName\'s profile on CuliNect!',
      imageUrl: photoURL ?? '', // Use empty string if photoURL is null
    );

    final lp = FlutterBranchSdk.BranchLinkProperties(
      channel: 'social_media',
      feature: 'app_feature',
      stage: 'user_interaction',
      tags: ['profile', 'culinect'],
      alias: 'customAlias',
    );

    lp.addControlParam('\$fallback_url', 'https://culinect.com/users/$userId');

    try {
      final response = await FlutterBranchSdk.FlutterBranchSdk.getShortUrl(
          buo: buo, linkProperties: lp);
      if (response.success) {
        return response.result;
      } else {
        print(
            'Error generating short URL: ${response.errorCode} - ${response.errorMessage}');
        return null;
      }
    } catch (error) {
      // Handle unexpected errors
      print('Error generating short URL: $error');
      return null;
    }
  }

  void showGeneratedLink(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generated Link'),
          content: Text(link),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
