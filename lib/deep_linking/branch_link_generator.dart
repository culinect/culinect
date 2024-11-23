import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class BranchLinkGenerator {
  static Future<String> generateUserLink(
      String userId, String displayName, String photoUrl) async {
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

    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

    if (response.success) {
      return response.result;
    } else {
      throw Exception('Error generating link: ${response.errorMessage}');
    }
  }

  static Future<String> generatePostLink(
      String postId, String postText, String imageUrl) async {
    String canonicalIdentifier = 'posts/$postId';

    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: canonicalIdentifier,
      canonicalUrl: 'https://culinect.com/posts/$postId',
      title: 'CuliNect Post',
      contentDescription: postText,
      imageUrl: imageUrl,
      keywords: ['post', 'culinect'],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata('post_id', postId)
        ..addCustomMetadata('post_type', 'posts'),
    );

    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'social',
        feature: 'post',
        alias: 'posts/$postId',
        stage: 'new post',
        tags: ['post', 'culinect'])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$always_deeplink', true)
      ..addControlParam('\$desktop_url', 'https://culinect.com/posts/$postId');

    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);

    if (response.success) {
      return response.result;
    } else {
      throw Exception('Error generating link: ${response.errorMessage}');
    }
  }

  static Future<void> generateQrCode(String userId, BranchUniversalObject buo,
      BranchLinkProperties lp, String imageURL) async {
    BranchResponse responseQrCodeImage =
        await FlutterBranchSdk.getQRCodeAsImage(
      buo: buo,
      linkProperties: lp,
      qrCode: BranchQrCode(
        primaryColor: Colors.black,
        centerLogoUrl: imageURL,
        backgroundColor: Colors.white,
        imageFormat: BranchImageFormat.PNG,
      ),
    );

    if (responseQrCodeImage.success) {
      try {
        print('QR Code Image Path: ${responseQrCodeImage.result}');

        Uint8List imageBytes =
            await File(responseQrCodeImage.result).readAsBytes();

        String path = 'users/$userId/qr/qr_$userId';
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref(path);

        await ref.putData(imageBytes);

        String downloadURL = await ref.getDownloadURL();

        print('Uploaded QR Code Image URL: $downloadURL');
      } catch (e) {
        print('Error while uploading QR Code Image: $e');
      }
    } else {
      print(
          'Error : ${responseQrCodeImage.errorCode} - ${responseQrCodeImage.errorMessage}');
    }
  }
}
