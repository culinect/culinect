import 'dart:io' if (dart.library.io) 'dart:typed_data';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:culinect/core/handlers/Company_profile/company_upload_image.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompanyImageUploaderIo implements CompanyImageUploader {
  @override
  Future<String> uploadImageToFirebase(String filePath) async {
    if (Platform.isIOS || Platform.isAndroid) {
      File file = File(filePath);
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final String fileName = path.basename(filePath);

      // Read the image file
      final Uint8List imageData = await file.readAsBytes();

      // Compress the image using flutter_image_compress
      final Uint8List compressedData = await FlutterImageCompress.compressWithList(
        imageData,
        minHeight: 1920,
        minWidth: 1080,
        quality: 95,
      );

      final Reference storageRef = FirebaseStorage.instance.ref('company/$uid/images/${DateTime.now().millisecondsSinceEpoch}_$fileName.webp');
      final UploadTask uploadTask = storageRef.putData(compressedData, SettableMetadata(contentType: 'image/webp'));
      await uploadTask.whenComplete(() => null);
      final String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } else {
      // Handle non-mobile platforms or add custom logic if needed
      throw UnsupportedError('CompanyImageUploaderIo is not supported on this platform.');
    }
  }
}

