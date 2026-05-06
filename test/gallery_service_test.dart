import 'package:flutter_test/flutter_test.dart';
import 'package:file/memory.dart';
import 'package:eday_app/gallery_service.dart';
import 'helpers.dart';

void main() {
  setupPathProviderMock();

  group('GalleryService', () {
    test('loadImages returns sorted jpg files', () async {
      final fs = MemoryFileSystem();
      final testDir = fs.directory('.')..createSync();

      // Create files with different modification dates
      // ignore: unused_local_variable
      final file1 = testDir.childFile('a.jpg')..createSync();
      await Future.delayed(const Duration(milliseconds: 10));
      final file2 = testDir.childFile('b.jpg')..createSync();

      final service = GalleryService(fileSystem: fs);
      final result = await service.loadImages();

      expect(result.length, 2);
      // Sorted descending: file2 should be first
      expect(result.first.path, file2.path);
    });

    test('loadImages ignores non-jpg files', () async {
      final fs = MemoryFileSystem();
      final testDir = fs.directory('.')..createSync();
      testDir.childFile('a.png').createSync();

      final service = GalleryService(fileSystem: fs);
      final result = await service.loadImages();

      expect(result.isEmpty, isTrue);
    });
  });
}
