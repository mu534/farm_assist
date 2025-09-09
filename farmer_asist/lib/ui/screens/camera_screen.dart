import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;
    final XFile file = await _controller!.takePicture();

    // Navigate to GalleryScreen and pass the captured image
    final selectedImagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryScreen(initialImage: file),
      ),
    );

    if (selectedImagePath != null) {
      // Placeholder: Send this image path to AI detection
      print('Selected image for AI: $selectedImagePath');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Capture Plant Image', style: AppTextStyles.heading2),
        backgroundColor: AppColors.backgroundLight,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
      ),
      body: _isInitialized
          ? Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _takePicture,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: AppColors.accentEmerald,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
