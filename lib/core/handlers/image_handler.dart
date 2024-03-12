import 'dart:io';
import 'dart:typed_data';
import 'package:culinect/core/storage_service.dart';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';
import 'package:image_editor_plus/image_editor_plus.dart';


class ImageHandler {
  final StorageService _storageService;

  ImageHandler(this._storageService);

  Future<String> uploadImage(File imageFile, String folderName, String fileName) async {
    return await _storageService.uploadFile(imageFile, folderName, fileName);
  }

  Future<void> deleteImage(String imageUrl) async {
    await _storageService.deleteFile(imageUrl);
  }

  Future<Uint8List> compressImage(File imageFile, {int quality = 70}) async {
    img.Image? imageObject = img.decodeImage(await imageFile.readAsBytes());
    if (imageObject != null) {
      return img.encodeJpg(imageObject, quality: quality);
    }
    throw Exception('Failed to compress image');
  }

  File rotateImage(File imageFile, int degrees) {
    img.Image? imageObject = img.decodeImage(imageFile.readAsBytesSync());
    if (imageObject != null) {
      img.Image rotatedImage = img.copyRotate(imageObject, angle: degrees);
      imageFile.writeAsBytesSync(img.encodeJpg(rotatedImage));
      return imageFile;
    }
    throw Exception('Failed to rotate image');
  }

  File cropImage(File imageFile, int x, int y, int width, int height) {
    img.Image? imageObject = img.decodeImage(imageFile.readAsBytesSync());
    if (imageObject != null) {
      img.Image croppedImage = img.copyCrop(imageObject, x: x, y: y, width: width, height: height);
      imageFile.writeAsBytesSync(img.encodeJpg(croppedImage));
      return imageFile;
    }
    throw Exception('Failed to crop image');
  }

  Uint8List generateThumbnail(File imageFile, {int width = 100, int height = 100}) {
    img.Image? imageObject = img.decodeImage(imageFile.readAsBytesSync());
    if (imageObject != null) {
      img.Image thumbnail = img.copyResize(imageObject, width: width, height: height);
      return img.encodeJpg(thumbnail);
    }
    throw Exception('Failed to generate thumbnail');
  }



  Future<Map<String, IfdTag>> readExifData(File imageFile) async {
    final Map<String, IfdTag> data = await readExifFromBytes(await imageFile.readAsBytes());
    if (data.isEmpty || data.values.every((tag) => tag == null)) {
      throw Exception('No EXIF data found');
    }
    return data;
  }


}
