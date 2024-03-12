import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:path/path.dart';
import '../imports.dart';

class BranchLinkGenerator {
  static Future<String> generateUserLink(String userId, String displayName, String photoUrl) async {
    // Customize the canonical identifier to include the 'users' path segment
    String canonicalIdentifier = 'users/$userId';

    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: canonicalIdentifier,
      canonicalUrl: 'https://culinect.com/users/$userId',
      title: 'CuliNector Portfolio',
      contentDescription: 'Check Out Chef $displayName profile on CuliNect',
      imageUrl: photoUrl,
      keywords: ['user', 'profile'],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('user_id', userId)
        ..addCustomMetadata('user_type', 'users'),
    );

    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'social',
        feature: 'user_profile',
        alias: 'users/$userId',
        stage: 'new user',
        tags: ['user', 'profile'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$desktop_url', 'https://culinect.com/users/$userId');
    BranchResponse response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    //generateQrCode(userId, buo, lp, 'https://firebasestorage.googleapis.com/v0/b/culinect-social.appspot.com/o/culinect_logo.png?alt=media&token=c297b0b1-0f37-4c7e-8de2-2d925d9902fe');

    if (response.success) {
            return response.result;

    } else {
      throw Exception('Error generating link: ${response.errorMessage}');
    }

  }

  static Future<void> generateQrCode(String userId, BranchUniversalObject buo, BranchLinkProperties lp, String imageURL) async {
    BranchResponse responseQrCodeImage =
    await FlutterBranchSdk.getQRCodeAsImage(
        buo: buo,
        linkProperties: lp,
        qrCode: BranchQrCode(
            primaryColor: Colors.black,
            centerLogoUrl: imageURL,
            backgroundColor: Colors.white,
            imageFormat: BranchImageFormat.PNG));
    if (responseQrCodeImage.success) {
      try {
        print('QR Code Image Path: ${responseQrCodeImage.result}');

        // Convert the image file to a byte array
        Uint8List imageBytes = await File(responseQrCodeImage.result).readAsBytes();

        // Create a reference to the location you want to upload to in Firebase Storage
        String path = 'users/$userId/qr/qr_$userId';
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(path);

        // Upload the file to Firebase Storage
        await ref.putData(imageBytes);

        // You can also get the download URL after uploading the file
        String downloadURL = await ref.getDownloadURL();

        print('Uploaded QR Code Image URL: $downloadURL');
      } catch (e) {
        // Handle any errors
        print('Error while uploading QR Code Image: $e');

      }
    } else {
      print('Error : ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}');


    }
  }
}
