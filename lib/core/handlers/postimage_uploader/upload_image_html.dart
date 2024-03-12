import 'package:culinect/core/handlers/postimage_uploader/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;  // Import the image package


class ImageUploaderHtml implements PostImageUploader {
  @override
  Future<String> uploadImageToFirebase(String filePath) async {
    if (kIsWeb) {
      try {
        final http.Response response = await http.get(Uri.parse(filePath));

        if (response.statusCode == 200) {
          final Uint8List data = response.bodyBytes;
          final String uid = FirebaseAuth.instance.currentUser!.uid;
          final Reference storageRef = FirebaseStorage.instance.ref('posts/$uid/images/${DateTime.now().millisecondsSinceEpoch}.webp');

          final Uint8List webpData = data;  // No conversion needed for WebP

          final UploadTask uploadTask = storageRef.putData(webpData, SettableMetadata(contentType: 'image/webp'));
          await uploadTask.whenComplete(() => null);
          final String downloadURL = await storageRef.getDownloadURL();
          return downloadURL;
        } else {
          throw Exception('Failed to retrieve the image from the web.');
        }
      } catch (e) {
        throw Exception('Error uploading the image: $e');
      }
    } else {
      throw UnsupportedError('ImageUploaderHtml is not supported on this platform.');
    }
  }
}