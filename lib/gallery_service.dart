import 'package:file/file.dart';
import 'package:path_provider/path_provider.dart';

class GalleryService {
  final FileSystem _fileSystem;

  GalleryService({required FileSystem fileSystem}) : _fileSystem = fileSystem;

  Future<List<File>> loadImages() async {
    try {
      final directoryPath = (await getApplicationDocumentsDirectory()).path;
      final directory = _fileSystem.directory(directoryPath);
      final files = directory.listSync();

      List<File> images = [];
      for (var file in files) {
        if (file.path.endsWith('.jpg')) {
          images.add(_fileSystem.file(file.path));
        }
      }

      // Sort by modified date descending
      images.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
      return images;
    } catch (_) {
      return [];
    }
  }
}
