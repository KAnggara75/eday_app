import 'package:camera/camera.dart';

class CameraControllerService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) return;

    CameraDescription? frontCamera;
    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }
    frontCamera ??= cameras.first;

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  double get aspectRatio {
    if (_controller == null || !_controller!.value.isInitialized) return 1.0;
    return _controller!.value.aspectRatio;
  }
}
