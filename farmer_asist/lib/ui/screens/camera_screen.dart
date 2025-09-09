import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/gallery_screen.dart';
import 'package:farmer_asist/ui/screens/result_screen.dart';
import 'package:farmer_asist/ui/services/ai_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false; // prevent multiple taps

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization failed: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (!(_controller?.value.isInitialized ?? false) || _isTakingPicture) {
      return;
    }

    try {
      setState(() => _isTakingPicture = true);

      final XFile file = await _controller!.takePicture();

      // Navigate to GalleryScreen to preview image
      final selectedImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryScreen(initialImage: file),
        ),
      );

      if (selectedImagePath != null) {
        // Run AI detection
        final aiService = AIService();
        final result = await aiService.predictPlantDisease(selectedImagePath);

        if (!mounted) return;

        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take picture.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
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
                    child: _isTakingPicture
                        ? const CircularProgressIndicator(
                            color: AppColors.accentEmerald,
                          )
                        : ElevatedButton(
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
