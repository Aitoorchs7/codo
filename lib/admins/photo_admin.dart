import 'package:codo/admins/photo_failure.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

class PhotoAdmin {
  PhotoAdmin({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  // Devuelve los bytes de la foto, o null si el usuario cancela
  Future<Uint8List?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      );
      if (file == null) return null;
      return await file.readAsBytes();
    } on PlatformException catch (e) {
      throw PhotoFailure(switch (e.code) {
        'camera_access_denied' => PhotoError.cameraDenied,
        'photo_access_denied' => PhotoError.galleryDenied,
        'no_available_camera' => PhotoError.noCamera,
        _ => PhotoError.unknown,
      });
    }
  }
}