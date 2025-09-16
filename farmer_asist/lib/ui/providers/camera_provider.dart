import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:farmer_asist/ui/models/plant_disease_model.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? controller;
  bool isDetecting = false;

  /// ML Kit labels detected from the camera
  List<ImageLabel> labels = [];

  /// Detected disease info (nullable)
  PlantDiseaseModel? detectedDisease;

  /// ML Kit Image Labeler
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  /// Initialize camera and start real-time detection
  Future<void> initializeCamera(CameraDescription camera) async {
    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller!.initialize();

    await controller!.startImageStream(_processCameraImage);

    notifyListeners();
  }

  /// Convert CameraImage to InputImage
  InputImage _convertCameraImage(CameraImage image) {
    final allBytes = image.planes.fold<Uint8List>(
      Uint8List(0),
      (previous, plane) => Uint8List.fromList(previous + plane.bytes),
    );

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      bytesPerRow: image.planes[0].bytesPerRow,
      format: InputImageFormat.bgra8888,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }

  /// Process camera frames
  void _processCameraImage(CameraImage image) async {
    if (isDetecting) return;
    isDetecting = true;

    try {
      final inputImage = _convertCameraImage(image);
      labels = await _imageLabeler.processImage(inputImage);

      if (labels.isNotEmpty) {
        final topLabel = labels.first;
        detectedDisease = PlantDiseaseModel(
          diseaseName: topLabel.label,
          recommendation: 'Check plant health guide',
          confidence: topLabel.confidence,
        );
      } else {
        detectedDisease = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Detection error: $e');
    } finally {
      isDetecting = false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _imageLabeler.close();
    super.dispose();
  }
}
