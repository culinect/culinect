import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderHtml.dart';
import 'package:culinect/core/handlers/image_uploader/RecipeImageUploaderIo.dart';

abstract class RecipeImageUploader {
  Future<String> uploadImageToFirebase(String filePath);
}

class RecipeImageUploaderFactory {
  static Object createUploader() {
    if (kIsWeb) {
      return RecipeImageUploaderHtml();
    } else {
      return RecipeImageUploaderIo();
    }
  }
}
