import 'dart:io' as io;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'github_sync_service.dart';
import 'gallery_service.dart';
import 'full_screen_image.dart';

class GalleryScreen extends StatefulWidget {
  final FileSystem? fileSystem;
  final GithubSyncService? syncService;
  const GalleryScreen({super.key, this.fileSystem, this.syncService});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late final FileSystem _fileSystem;
  late final GalleryService _galleryService;
  List<File> _images = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  int _syncTotal = 0;
  int _syncCurrent = 0;

  @override
  void initState() {
    super.initState();
    _fileSystem = widget.fileSystem ?? const LocalFileSystem();
    _galleryService = GalleryService(fileSystem: _fileSystem);
    _loadImages();
  }

  Future<void> _loadImages() async {
    final images = await _galleryService.loadImages();
    if (mounted) {
      setState(() {
        _images = images;
        _isLoading = false;
      });
    }
  }

  Future<void> _syncToGithub() async {
    if (_images.isEmpty) return;
    String? token = dotenv.env['GITHUB_PAT'];
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GITHUB_PAT not found in .env')),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncTotal = _images.length;
      _syncCurrent = 0;
    });

    final owner = dotenv.env['GITHUB_OWNER'] ?? 'KAnggara75';
    final repo = dotenv.env['GITHUB_REPO'] ?? 'everyday';

    final syncService =
        widget.syncService ??
        GithubSyncService(token: token, owner: owner, repo: repo);
    await syncService.syncFiles(_images, (current, total) {
      if (mounted) {
        setState(() {
          _syncCurrent = current;
          _syncTotal = total;
        });
      }
    });

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      _loadImages(); // Refresh local list as files are deleted
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sync completed!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri'),
        actions: [
          if (_isSyncing)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('$_syncCurrent/$_syncTotal'),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: _isSyncing ? null : _syncToGithub,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
          ? const Center(child: Text('Belum ada gambar'))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          images: _images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Image.file(
                    io.File(_images[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
