import 'package:image_picker/image_picker.dart';

/// The camera, behind a hook.
///
/// Overridable so tests can stand in for it: under `flutter_test` there is no
/// picker to answer, and a button that waits on a photo can never be reached.
class Camera {
  const Camera._();

  /// Takes a photo and returns its path, or null if the person backed out.
  static Future<String?> Function() takePhoto = _fromCamera;

  static Future<String?> _fromCamera() async {
    final shot = await ImagePicker().pickImage(
      source: ImageSource.camera,
      // A clock-in selfie is a record, not a portrait, and it goes up over a
      // phone plan.
      maxWidth: 1200,
      imageQuality: 70,
      preferredCameraDevice: CameraDevice.front,
    );
    return shot?.path;
  }

  /// Photographs a document with the back camera and returns its path, or null
  /// if the person backed out. Larger and sharper than [takePhoto]: the text on
  /// a paper has to stay readable.
  static Future<String?> Function() takeDocument = _document;

  static Future<String?> _document() async {
    final shot = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    return shot?.path;
  }
}
