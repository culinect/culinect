import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:culinect/core/handlers/postimage_uploader/upload_image_html.dart';
import 'package:culinect/core/handlers/postimage_uploader/upload_image_io.dart';

abstract class PostImageUploader {
  Future<String> uploadImageToFirebase(String filePath);
}
class RecipeImageUploaderFactory {
  static Object createUploader() {
    if (kIsWeb) {
      return ImageUploaderHtml();
    } else {
      return ImageUploaderIo();
    }
  }
}