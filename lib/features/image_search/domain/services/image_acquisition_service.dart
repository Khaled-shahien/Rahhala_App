import 'dart:io';

/// Abstraction for image acquisition (camera/gallery).
///
/// This allows [ImageSearchCubit] to remain decoupled from
/// `image_picker` and makes the cubit easily testable.
abstract class ImageAcquisitionService {
  /// Capture an image from the device camera.
  ///
  /// Returns the captured image file, or `null` if the user
  /// cancels the operation.
  Future<File?> captureFromCamera();

  /// Pick an image from the device gallery.
  ///
  /// Returns the picked image file, or `null` if the user
  /// cancels the operation.
  Future<File?> pickFromGallery();
}
