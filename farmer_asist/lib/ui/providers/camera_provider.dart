import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/plant_disease_model.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? controller;
  bool isDetecting = false;
  List<ImageLabel> labels = [];
  PlantDiseaseModel? detectedDisease;

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

    // Start image stream
    await controller!.startImageStream(_processCameraImage);

    notifyListeners();
  }

  /// Convert CameraImage to InputImage (supports YUV420 and BGRA8888)
  InputImage _convertCameraImage(CameraImage image) {
    // Concatenate all plane bytes
    final allBytes = image.planes.fold<Uint8List>(
      Uint8List(0),
      (previous, plane) => Uint8List.fromList(previous + plane.bytes),
    );

    // Detect format dynamically
    InputImageFormat format;
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        format = InputImageFormat.yuv420;
        break;
      case ImageFormatGroup.bgra8888:
        format = InputImageFormat.bgra8888;
        break;
      default:
        throw Exception('Unsupported image format: ${image.format.group}');
    }

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      bytesPerRow: image.planes[0].bytesPerRow,
      format: format,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }

  /// Process camera frames in real-time
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
