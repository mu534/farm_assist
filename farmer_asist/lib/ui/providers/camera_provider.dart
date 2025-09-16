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

  /// Process camera image stream
  void _processCameraImage(CameraImage image) async {
    if (isDetecting) return;
    isDetecting = true;

    try {
      final inputImage = _convertCameraImage(image);
      final imageLabels = await _imageLabeler.processImage(inputImage);
      labels = imageLabels;
      // Optionally, map labels to PlantDiseaseModel here
      notifyListeners();
    } catch (e) {
      // Handle error
    } finally {
      isDetecting = false;
    }
  }

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
    if (image.format.group != ImageFormatGroup.yuv420 &&
        image.format.group != ImageFormatGroup.bgra8888) {
      throw Exception('Unsupported image format: ${image.format.group}');
    }

    final allBytes = image.planes.fold<Uint8List>(
      Uint8List(0),
      (prev, plane) => Uint8List.fromList(prev + plane.bytes),
    );

    final format = image.format.group == ImageFormatGroup.yuv420
        ? InputImageFormat.yuv420
        : InputImageFormat.bgra8888;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      bytesPerRow: image.planes[0].bytesPerRow,
      format: format,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }
}
