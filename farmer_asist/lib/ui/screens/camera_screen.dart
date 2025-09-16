import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../providers/camera_provider.dart';
import 'result_screen.dart';
import '/core/themes.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final cameraProvider = Provider.of<CameraProvider>(
        context,
        listen: false,
      );
      if (cameraProvider.controller != null &&
          cameraProvider.controller!.value.isInitialized) {
        setState(() => _isInitialized = true);
      }
    }
  }

  Future<void> _captureLeaf() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final controller = cameraProvider.controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (!mounted) return;

      // Navigate to ResultScreen with captured image
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(imagePath: file.path)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Capture error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: _isInitialized && cameraProvider.controller != null
              ? Stack(
                  children: [
                    CameraPreview(cameraProvider.controller!),
                    // Live ML Kit overlay
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: Text(
                            cameraProvider.labels.isNotEmpty
                                ? 'Detected: ${cameraProvider.labels.first.label}'
                                : 'Detecting plant...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Capture button
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _captureLeaf,
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
      },
    );
  }
}
