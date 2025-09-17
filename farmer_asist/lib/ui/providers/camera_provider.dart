import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../models/plant_disease_model.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? controller;
  bool isDetecting = false;
  List<ImageLabel> labels = [];
  PlantDiseaseModel? detectedDisease;
  List<DetectedObject> detectedObjects = [];
  List<Rect> plantBoxes = [];
  bool isPlantInFrame = false;
  double zoomLevel = 1.0;
  double minZoom = 1.0;
  double maxZoom = 1.0;
  FlashMode flashMode = FlashMode.off;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );

  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.stream,
    ),
  );

  /// Process camera image stream
  void _processCameraImage(CameraImage image) async {
    if (isDetecting) return;
    isDetecting = true;

    try {
      final inputImage = _convertCameraImage(image);

      // Lightweight global labels (optional info text)
      labels = await _imageLabeler.processImage(inputImage);

      // Object detection with classification -> find plant-like objects
      detectedObjects = await _objectDetector.processImage(inputImage);

      // Filter objects labeled as Plant (or similar)
      final List<Rect> newPlantBoxes = [];
      bool plantFound = false;
      for (final obj in detectedObjects) {
        final hasPlantLabel = obj.labels.any((l) {
          final label = l.text.toLowerCase();
          return (label.contains('plant') || label.contains('leaf') || label.contains('tree') || label.contains('flower') || label.contains('vegetation')) && l.confidence >= 0.5;
        });
        if (hasPlantLabel) {
          plantFound = true;
          newPlantBoxes.add(obj.boundingBox);
        }
      }
      plantBoxes = newPlantBoxes;
      isPlantInFrame = plantFound;

      notifyListeners();
    } catch (e) {
      // Handle error
    } finally {
      isDetecting = false;
    }
  }

  /// Initialize camera and start real-time detection
  Future<void> initializeCamera(List<CameraDescription>? cameras, {int initialIndex = 0}) async {
    _cameras = (cameras == null || cameras.isEmpty) ? await availableCameras() : cameras;
    _currentCameraIndex = initialIndex.clamp(0, _cameras.length - 1);

    controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller!.initialize();

    // Zoom limits
    minZoom = await controller!.getMinZoomLevel();
    maxZoom = await controller!.getMaxZoomLevel();
    zoomLevel = 1.0;

    // Start image stream
    await controller!.startImageStream(_processCameraImage);

    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await controller?.stopImageStream();
    await controller?.dispose();
    controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller!.initialize();
    await controller!.startImageStream(_processCameraImage);
    notifyListeners();
  }

  Future<void> toggleFlash() async {
    if (controller == null) return;
    flashMode = flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await controller!.setFlashMode(flashMode);
    notifyListeners();
  }

  Future<void> setZoom(double value) async {
    if (controller == null) return;
    zoomLevel = value.clamp(minZoom, maxZoom);
    await controller!.setZoomLevel(zoomLevel);
    notifyListeners();
  }

  Future<void> setFocusPoint(Offset point) async {
    if (controller == null) return;
    try {
      await controller!.setFocusPoint(point);
    } catch (_) {}
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
