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
  CameraController? _cameraController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "No cameras found on this device.";
        });
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e, s) {
      debugPrint("Camera initialization error: $e\n$s");
      setState(() {
        _errorMessage =
            "Failed to initialize camera.\nPlease check permissions or use a real device.";
      });
    }
  }

  Future<void> _captureImage() async {
    if (!(_cameraController?.value.isInitialized ?? false)) return;

    try {
      final image = await _cameraController!.takePicture();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryScreen(initialImage: image),
        ),
      );
    } catch (e) {
      debugPrint('Error capturing image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
      ),
      body: _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : _isInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: const Text(
                      'Frame the plant leaf properly',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(24),
                        backgroundColor: AppColors.primaryIndigo,
                      ),
                      onPressed: _captureImage,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
