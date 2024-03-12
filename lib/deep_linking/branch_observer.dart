import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // Check if the pushed route is a MaterialPageRoute
    if (route is MaterialPageRoute) {
      // Extract deep link data from the route settings
      final deepLinkData = route.settings.arguments as Map<String, dynamic>?;

      // Check if deep link data is available
      if (deepLinkData != null) {
        handleDeepLink(deepLinkData);
      }
    }
  }

  void handleDeepLink(Map<String, dynamic> deepLinkData) {
    // Implement logic to handle deep link based on the data
    // For example, you can extract data like post ID, user ID, etc.,
    // and navigate to the corresponding screen or perform actions.
    // You can switch on the deep link type or use a specific parameter to identify the type.

    // Example:
    final deepLinkType = deepLinkData['type'];
    switch (deepLinkType) {
      case 'post':
        final postId = deepLinkData['postId'];
        // Navigate to the post screen using the postId
        // Navigator.pushNamed(context, AppRoutes.postDetails, arguments: postId);
        break;
      case 'user':
        final userId = deepLinkData['userId'];
        // Navigate to the user profile screen using the userId
        // Navigator.pushNamed(context, AppRoutes.userProfile, arguments: userId);
        break;
    // Add more cases for other deep link types
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    // Implement similar logic to handle deep links when routes are replaced
    // You can extract deep link data from the new route settings and handle it.
  }

// Add other methods from NavigatorObserver if needed
}
