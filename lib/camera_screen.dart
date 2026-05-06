import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'gallery_screen.dart';
import 'image_processor_service.dart';
import 'github_api_service.dart';
import 'camera_controller_service.dart';
import 'camera_capture_service.dart';
import 'camera_screen_body.dart';
import 'camera_view_model.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final FileSystem? fileSystem;

  const CameraScreen({super.key, required this.cameras, this.fileSystem});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraViewModel _vm = CameraViewModel();
  late final FileSystem _fileSystem;
  late final ImageProcessorService _imageProcessor;
  late final GithubApiService _githubApi;
  late final CameraControllerService _cameraService;
  late final CameraCaptureService _captureService;

  @override
  void initState() {
    super.initState();
    _fileSystem = widget.fileSystem ?? const LocalFileSystem();
    _imageProcessor = ImageProcessorService();
    _githubApi = GithubApiService();
    _cameraService = CameraControllerService();
    _captureService = CameraCaptureService(
      fileSystem: _fileSystem,
      imageProcessor: _imageProcessor,
    );
    _initCamera();
    _fetchGuidelineImage();
  }

  Future<void> _fetchGuidelineImage() async {
    String? token = dotenv.env['GITHUB_PAT'];
    if (token == null || token.isEmpty) return;
    _vm.isLoadingGuideline = true;

    try {
      final owner = dotenv.env['GITHUB_OWNER'] ?? 'KAnggara75';
      final repo = dotenv.env['GITHUB_REPO'] ?? 'everyday';
      const targetPath = 'timelapse/last.jpg';

      final bytes = await _githubApi.fetchGuidelineImage(
        owner: owner,
        repo: repo,
        targetPath: targetPath,
        token: token,
      );

      if (bytes != null) {
        _vm.guidelineBytes = bytes;
      }
    } catch (e) {
      debugPrint('Error fetching guideline: $e');
    } finally {
      _vm.isLoadingGuideline = false;
    }
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initialize(widget.cameras);
      if (mounted) {
        _vm.isInit = true;
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  double get _cameraVisualRatio {
    if (!_cameraService.isInitialized) return 1.0;
    double ratio = _cameraService.aspectRatio;
    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isLandscape && ratio < 1) return 1 / ratio;
    if (!isLandscape && ratio > 1) return 1 / ratio;
    return ratio;
  }

  Future<void> _takePicture() async {
    if (!_cameraService.isInitialized || _vm.isProcessing) {
      return;
    }

    _vm.isProcessing = true;

    try {
      final savePath = await _captureService.captureAndProcess(
        controller: _cameraService.controller!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tersimpan di: $savePath'),
            duration: const Duration(milliseconds: 300),
          ),
        );

        _vm.previewImagePath = savePath;

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _vm.previewImagePath = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengambil selfie: $e')));
      }
    } finally {
      if (mounted) {
        _vm.isProcessing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      );
    }

    if (!_vm.isInit) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: CameraScreenBody(
            cameraService: _cameraService,
            showGuideline: _vm.showGuideline,
            isLoadingGuideline: _vm.isLoadingGuideline,
            guidelineBytes: _vm.guidelineBytes,
            previewImagePath: _vm.previewImagePath,
            isProcessing: _vm.isProcessing,
            cameraVisualRatio: _cameraVisualRatio,
            onToggleGuideline: _vm.toggleGuideline,
            onOpenGallery: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GalleryScreen()),
              );
            },
            onTakePicture: _takePicture,
          ),
        );
      },
    );
  }
}
