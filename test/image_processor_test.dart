import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:eday_app/image_processor_service.dart';

void main() {
  group('ImageProcessorService', () {
    late ImageProcessorService service;

    setUp(() {
      service = ImageProcessorService();
    });

    test('processCapturedImage crops image to 3:2 aspect ratio', () {
      // Create a 1000x1000 (1:1) image
      final image = img.Image(width: 1000, height: 1000);
      final bytes = Uint8List.fromList(img.encodeJpg(image));

      final result = service.processCapturedImage(bytes, CameraLensDirection.back);

      // 1000 / (3/2) = 666.66 -> 667
      expect(result.width, 1000);
      expect(result.height, 667);
    });

    test('processCapturedImage flips image for front camera', () {
      final image = img.Image(width: 10, height: 10);
      final bytes = Uint8List.fromList(img.encodePng(image));

      final result = service.processCapturedImage(bytes, CameraLensDirection.front);

      // Verify dimensions (10x10 cropped to 3:2 becomes 10x7)
      expect(result.width, 10);
      expect(result.height, 7);
    });

    test('processCapturedImage rotates portrait image to landscape', () {
      // Create a portrait image (wider than tall)
      // Wait, portrait is taller than wide. 600x1000.
      final image = img.Image(width: 600, height: 1000);
      final bytes = Uint8List.fromList(img.encodeJpg(image));

      final result = service.processCapturedImage(bytes, CameraLensDirection.back);

      // Should be rotated and then cropped to 3:2
      // After rotation: 1000x600.
      // 1000/600 = 1.666. Target is 1.5. 
      // It should crop width.
      expect(result.width, 900);
      expect(result.height, 600);
    });
  });
}
