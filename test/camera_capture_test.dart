import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eday_app/camera_capture_service.dart';
import 'package:eday_app/image_processor_service.dart';
import 'package:image/image.dart' as img;
import 'helpers.dart';

class MockCameraController extends Mock implements CameraController {}

class MockImageProcessor extends Mock implements ImageProcessorService {}

class MockCameraDescription extends Mock implements CameraDescription {}

void main() {
  setupPathProviderMock();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(CameraLensDirection.front);
  });
  group('CameraCaptureService', () {
    late CameraCaptureService service;
    late MemoryFileSystem fs;
    late MockImageProcessor mockProcessor;
    late MockCameraController mockController;

    setUp(() {
      fs = MemoryFileSystem();
      mockProcessor = MockImageProcessor();
      mockController = MockCameraController();
      service = CameraCaptureService(
        fileSystem: fs,
        imageProcessor: mockProcessor,
      );
    });

    test('captureAndProcess captures, processes, and saves image', () async {
      // Mock takePicture
      final tempFile = fs.file('temp.jpg')..createSync();
      final dummyImage = img.Image(width: 10, height: 10);
      tempFile.writeAsBytesSync(img.encodeJpg(dummyImage));

      when(
        () => mockController.takePicture(),
      ).thenAnswer((_) async => XFile(tempFile.path));

      final mockDesc = MockCameraDescription();
      when(() => mockDesc.lensDirection).thenReturn(CameraLensDirection.front);
      when(() => mockController.description).thenReturn(mockDesc);

      when(
        () => mockProcessor.processCapturedImage(any(), any()),
      ).thenReturn(dummyImage);

      final result = await service.captureAndProcess(
        controller: mockController,
      );

      expect(result, contains('.jpg'));
      expect(fs.file(result).existsSync(), isTrue);
    });
  });
}
