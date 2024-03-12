import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchService {
  Future<String> generateLink(BranchUniversalObject buo, BranchLinkProperties lp) async {
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      return response.result;
    } else {
      throw Exception('Error generating link: ${response.errorMessage}');
    }
  }

  Stream<Map<dynamic, dynamic>> initSession() {
    return FlutterBranchSdk.listSession();
  }

  Future<void> handleDeepLink(String? link) async {
    if (link != null) {
      FlutterBranchSdk.handleDeepLink(link);
    }
  }
}
