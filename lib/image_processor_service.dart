import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class ImageProcessorService {
  /// Processes the captured bytes: bakes orientation, flips if front camera,
  /// and crops to 3:2 aspect ratio.
  img.Image processCapturedImage(
    Uint8List bytes,
    CameraLensDirection lensDirection,
  ) {
    // Decode image
    img.Image? capturedImage = img.decodeImage(bytes);
    if (capturedImage == null) throw Exception("Failed to decode image");

    // Bake orientation from EXIF
    capturedImage = img.bakeOrientation(capturedImage);

    // Force landscape if needed
    if (capturedImage.width < capturedImage.height) {
      capturedImage = img.copyRotate(capturedImage, angle: -90);
    }

    // Flip if front camera
    if (lensDirection == CameraLensDirection.front) {
      capturedImage = img.flipHorizontal(capturedImage);
    }

    // Target aspect ratio is 3:2
    const double targetRatio = 3 / 2;

    int srcWidth = capturedImage.width;
    int srcHeight = capturedImage.height;
    double srcRatio = srcWidth / srcHeight;

    img.Image finalImage;

    if (srcRatio.toStringAsFixed(3) != targetRatio.toStringAsFixed(3)) {
      if (srcRatio > targetRatio) {
        // Source is wider than target. Crop width.
        int newWidth = (srcHeight * targetRatio).round();
        int offsetX = (srcWidth - newWidth) ~/ 2;
        finalImage = img.copyCrop(
          capturedImage,
          x: offsetX,
          y: 0,
          width: newWidth,
          height: srcHeight,
        );
      } else {
        // Source is taller than target. Crop height.
        int newHeight = (srcWidth / targetRatio).round();
        int offsetY = (srcHeight - newHeight) ~/ 2;
        finalImage = img.copyCrop(
          capturedImage,
          x: 0,
          y: offsetY,
          width: srcWidth,
          height: newHeight,
        );
      }
    } else {
      finalImage = capturedImage;
    }

    return finalImage;
  }
}
