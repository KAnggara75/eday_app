import 'dart:typed_data';
import 'package:flutter/material.dart';

class CameraGuidelineOverlay extends StatelessWidget {
  final Uint8List? guidelineBytes;
  final bool showGuideline;
  final bool isLoading;

  const CameraGuidelineOverlay({
    super.key,
    this.guidelineBytes,
    required this.showGuideline,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGuideline) return const SizedBox.shrink();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (guidelineBytes != null) {
      return Opacity(
        opacity: 0.3,
        child: Image.memory(
          guidelineBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return const Center(
      child: Text(
        'Guideline not available',
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
