import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/screens/result_screen.dart';
import 'package:farmer_asist/ui/services/ai_service.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  // Framing box size (square)
  final double _frameSize = 250;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

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
    if (!(_controller?.value.isInitialized ?? false) || _isTakingPicture)
      return;

    try {
      setState(() => _isTakingPicture = true);

      final XFile file = await _controller!.takePicture();

      // Crop to frame
      final croppedFile = await _cropToFrame(file);

      final aiService = AIService();
      final result = await aiService.analyzeImage(croppedFile);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultScreen(result: result, imagePath: croppedFile.path),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture or process image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  /// Crops the image to the center square frame
  Future<File> _cropToFrame(XFile file) async {
    final bytes = await file.readAsBytes();
    img.Image? capturedImage = img.decodeImage(bytes);

    if (capturedImage == null) return File(file.path);

    final shortestSide = capturedImage.width < capturedImage.height
        ? capturedImage.width
        : capturedImage.height;

    // Center crop
    final offsetX = (capturedImage.width - shortestSide) ~/ 2;
    final offsetY = (capturedImage.height - shortestSide) ~/ 2;
    final cropped = img.copyCrop(
      capturedImage,
      x: offsetX,
      y: offsetY,
      width: shortestSide,
      height: shortestSide,
    );

    final croppedBytes = img.encodeJpg(cropped);
    final croppedFile = File('${file.path}_cropped.jpg');
    await croppedFile.writeAsBytes(croppedBytes);

    return croppedFile;
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

                // Framing rectangle
                Center(
                  child: Container(
                    width: _frameSize,
                    height: _frameSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.accentEmerald,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Instructions
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Align the plant inside the green box',
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
