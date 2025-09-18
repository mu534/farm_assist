import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'result_screen.dart';
import '/core/themes.dart';
import '../providers/camera_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isInitialized = false;
  List<CameraDescription> _cameras = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final cameraProvider = Provider.of<CameraProvider>(
        context,
        listen: false,
      );
      () async {
        try {
          // Let provider self-fetch camera list to avoid null/type issues
          await cameraProvider.initializeCamera(null);
        } catch (_) {}
        if (mounted) setState(() => _isInitialized = true);
      }();
    }
  }

  Future<void> _captureLeaf() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    final controller = cameraProvider.controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      // Allow capture even if plant is not detected; just warn the user
      if (!cameraProvider.isPlantInFrame) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No plant detected. Capturing anyway...')),
        );
      }
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

  Widget _buildGrid() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(color: Colors.white24),
        child: Container(),
      ),
    );
  }

  Widget _buildBoxes(CameraProvider provider) {
    return IgnorePointer(
      child: Stack(
        children: provider.plantBoxes
            .map((r) => Positioned(
                  left: r.left,
                  top: r.top,
                  width: r.width,
                  height: r.height,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: provider.isPlantInFrame ? Colors.greenAccent : Colors.yellow,
                        width: 2,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
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
                    _buildGrid(),
                    _buildBoxes(cameraProvider),
                    // Live ML Kit overlay
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cameraProvider.isPlantInFrame
                                    ? 'Plant detected'
                                    : 'Align a plant in the frame',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              if (cameraProvider.detectedObjects.isNotEmpty)
                                Text(
                                  'Objects: ${cameraProvider.detectedObjects.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: cameraProvider.toggleFlash,
                              icon: Icon(
                                cameraProvider.flashMode == FlashMode.off
                                    ? Icons.flash_off
                                    : Icons.flash_on,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                            ),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: _captureLeaf,
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                                backgroundColor: cameraProvider.isPlantInFrame
                                    ? AppColors.accentEmerald
                                    : Colors.grey,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 24),
                            IconButton(
                              onPressed: cameraProvider.switchCamera,
                              icon: const Icon(Icons.cameraswitch, color: Colors.white),
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: cameraProvider.testPlantDetection,
                              icon: const Icon(Icons.bug_report, color: Colors.white),
                              style: IconButton.styleFrom(backgroundColor: Colors.black45),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Zoom slider
                    Positioned(
                      right: 12,
                      top: 100,
                      bottom: 120,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Slider(
                          min: cameraProvider.minZoom,
                          max: cameraProvider.maxZoom,
                          value: cameraProvider.zoomLevel.clamp(
                              cameraProvider.minZoom, cameraProvider.maxZoom),
                          onChanged: cameraProvider.setZoom,
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

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // Rule of thirds grid
    final dx = size.width / 3;
    final dy = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(dx * i, 0), Offset(dx * i, size.height), paint);
      canvas.drawLine(Offset(0, dy * i), Offset(size.width, dy * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
