import 'package:image_picker/image_picker.dart';
class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  Future<XFile?> capture() => _picker.pickImage(source: ImageSource.camera, imageQuality: 95, preferredCameraDevice: CameraDevice.rear);
  Future<XFile?> pickFromGallery() => _picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
}
