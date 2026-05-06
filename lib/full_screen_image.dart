import 'package:flutter/material.dart';
import 'package:file/file.dart';

class FullScreenImage extends StatelessWidget {
  final List<File> images;
  final int initialIndex;

  const FullScreenImage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        itemCount: images.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.file(
                images[index]
                    as dynamic, // Support for memory file system in tests
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
