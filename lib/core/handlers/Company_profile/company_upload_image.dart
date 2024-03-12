import 'dart:io' if (dart.library.html) 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:culinect/core/handlers/Company_profile/company_upload_image_html.dart';
import 'package:culinect/core/handlers/Company_profile/company_upload_image_io.dart';
abstract class CompanyImageUploader {
  Future<String> uploadImageToFirebase(String filePath);
}

class RecipeImageUploaderFactory {
  static Object createUploader() {
    if (kIsWeb) {
      return CompanyImageUploaderHtml();
    } else {
      return CompanyImageUploaderIo();
    }
  }
}
