import 'dart:io';

import 'package:rahhala_app/core/services/image_picker_service.dart';
import 'package:rahhala_app/features/image_search/domain/services/image_acquisition_service.dart';

/// Concrete implementation of [ImageAcquisitionService].
class ImageAcquisitionServiceImpl implements ImageAcquisitionService {
  ImageAcquisitionServiceImpl({required ImagePickerService imagePickerService})
      : _imagePickerService = imagePickerService;

  final ImagePickerService _imagePickerService;

  @override
  Future<File?> captureFromCamera() {
    return _imagePickerService.pickImage(
      source: AppImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
    );
  }

  @override
  Future<File?> pickFromGallery() {
    return _imagePickerService.pickImage(
      source: AppImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
  }
}
