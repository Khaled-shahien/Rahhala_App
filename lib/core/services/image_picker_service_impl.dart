import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:rahhala_app/core/services/image_picker_service.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  ImagePickerServiceImpl({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<File?> pickImage({
    required AppImageSource source,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        AppImageSource.camera => ImageSource.camera,
        AppImageSource.gallery => ImageSource.gallery,
      },
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );

    return file == null ? null : File(file.path);
  }
}
