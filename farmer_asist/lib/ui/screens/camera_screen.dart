import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/providers/camera_provider.dart';
import 'package:farmer_asist/ui/screens/result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    await cameraProvider.initializeCamera(_cameras.first);

    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  Future<void> _captureLeaf() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final controller = cameraProvider.controller;

    if (controller == null || !controller.value.isInitialized) return;

    try {
      final XFile file = await controller.takePicture();
      if (!mounted) return;

      // Navigate even if no disease detected, but show message
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: cameraProvider.detectedDisease,
            imagePath: file.path,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(
              'Capture Plant Image',
              style: AppTextStyles.heading2,
            ),
            backgroundColor: AppColors.backgroundLight,
            elevation: 1,
            iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
          ),
          body: _isInitialized
              ? Stack(
                  children: [
                    // Camera preview
                    if (cameraProvider.controller != null)
                      CameraPreview(cameraProvider.controller!),

                    // Centered guide frame
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.accentEmerald,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Real-time detection label overlay
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cameraProvider.detectedDisease != null
                                ? '${cameraProvider.detectedDisease!.diseaseName} (${(cameraProvider.detectedDisease!.confidence * 100).toStringAsFixed(1)}%)'
                                : 'Detecting leaf...',
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
