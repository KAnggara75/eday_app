import 'package:camera/camera.dart';
import 'package:file/file.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'image_processor_service.dart';
import 'package:image/image.dart' as img;

class CameraCaptureService {
  final FileSystem _fileSystem;
  final ImageProcessorService _imageProcessor;

  CameraCaptureService({
    required FileSystem fileSystem,
    required ImageProcessorService imageProcessor,
  }) : _fileSystem = fileSystem,
       _imageProcessor = imageProcessor;

  Future<String> captureAndProcess({
    required CameraController controller,
  }) async {
    // 1. Capture the image
    final XFile imageFile = await controller.takePicture();

    // 2. Process image
    final File file = _fileSystem.file(imageFile.path);
    final bytes = await file.readAsBytes();

    final finalImage = _imageProcessor.processCapturedImage(
      bytes,
      controller.description.lensDirection,
    );

    // 3. Generate path
    final directory = await getApplicationDocumentsDirectory();
    String filename =
        "${DateFormat('yyMMddHHmmss').format(DateTime.now())}.jpg";
    String savePath = "${directory.path}/$filename";

    // 4. Save
    final savedFile = _fileSystem.file(savePath);
    await savedFile.writeAsBytes(img.encodeJpg(finalImage));

    return savePath;
  }
}
