import 'dart:io';

enum AppImageSource { camera, gallery }

abstract class ImagePickerService {
  Future<File?> pickImage({
    required AppImageSource source,
    int imageQuality,
    double? maxWidth,
    double? maxHeight,
  });
}
