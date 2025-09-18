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

  // Debug mode - set to false for production
  static const bool _debugMode = true;
  
  void _debugPrint(String message) {
    if (_debugMode) {
      // ignore: avoid_print
      print('[CameraProvider] $message');
    }
  }

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

      // Filter objects labeled as Plant (or similar) with more flexible detection
      final List<Rect> newPlantBoxes = [];
      bool plantFound = false;
      
      // Debug: Print detected objects for troubleshooting
      _debugPrint('Detected ${detectedObjects.length} objects');
      
      for (final obj in detectedObjects) {
        _debugPrint('Object labels: ${obj.labels.map((l) => '${l.text} (${l.confidence.toStringAsFixed(2)})').join(', ')}');
        
        final hasPlantLabel = obj.labels.any((l) {
          final label = l.text.toLowerCase();
          final plantKeywords = [
            'plant', 'leaf', 'leaves', 'tree', 'flower', 'vegetation', 
            'foliage', 'green', 'nature', 'garden', 'herb', 'shrub',
            'branch', 'stem', 'petal', 'bloom', 'crop', 'vegetable'
          ];
          
          final isPlantRelated = plantKeywords.any((keyword) => label.contains(keyword));
          final hasGoodConfidence = l.confidence >= 0.3; // Lowered threshold
          
          return isPlantRelated && hasGoodConfidence;
        });
        
        if (hasPlantLabel) {
          plantFound = true;
          newPlantBoxes.add(obj.boundingBox);
          _debugPrint('Plant detected: ${obj.labels.first.text}');
        }
      }
      
      // Also check image labels for plant-related content
      if (!plantFound && labels.isNotEmpty) {
        for (final label in labels) {
          final labelText = label.label.toLowerCase();
          final plantKeywords = [
            'plant', 'leaf', 'leaves', 'tree', 'flower', 'vegetation', 
            'foliage', 'green', 'nature', 'garden', 'herb', 'shrub',
            'branch', 'stem', 'petal', 'bloom', 'crop', 'vegetable'
          ];
          
          if (plantKeywords.any((keyword) => labelText.contains(keyword)) && label.confidence >= 0.3) {
            plantFound = true;
            _debugPrint('Plant detected via image labeling: $labelText');
            break;
          }
        }
      }
      
      plantBoxes = newPlantBoxes;
      isPlantInFrame = plantFound;

      notifyListeners();
    } catch (e) {
      _debugPrint('Error in plant detection: $e');
      // Reset detection state on error
      plantBoxes = [];
      isPlantInFrame = false;
      notifyListeners();
    } finally {
      isDetecting = false;
    }
  }

  /// Initialize camera and start real-time detection
  Future<void> initializeCamera(List<CameraDescription>? cameras, {int initialIndex = 0}) async {
    try {
    _cameras = (cameras == null || cameras.isEmpty) ? await availableCameras() : cameras;
      if (_cameras.isEmpty) {
        throw Exception('No cameras available on device');
      }
      
    _currentCameraIndex = initialIndex.clamp(0, _cameras.length - 1);
      _debugPrint('Initializing camera: ${_cameras[_currentCameraIndex].name}');

    controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller!.initialize();
      _debugPrint('Camera initialized successfully');

    // Zoom limits
    minZoom = await controller!.getMinZoomLevel();
    maxZoom = await controller!.getMaxZoomLevel();
    zoomLevel = 1.0;
      _debugPrint('Zoom range: $minZoom - $maxZoom');

    // Start image stream
    await controller!.startImageStream(_processCameraImage);
      _debugPrint('Image stream started');

    notifyListeners();
    } catch (e) {
      _debugPrint('Error initializing camera: $e');
      rethrow;
    }
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

  /// Manual method to test plant detection (for debugging)
  Future<void> testPlantDetection() async {
    if (controller == null || !controller!.value.isInitialized) {
      _debugPrint('Camera not initialized');
      return;
    }
    
    try {
      final image = await controller!.takePicture();
      _debugPrint('Test image captured: ${image.path}');
      // You can add additional processing here if needed
    } catch (e) {
      _debugPrint('Error capturing test image: $e');
    }
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

    InputImageRotation rotation = InputImageRotation.rotation0deg;
    try {
      final sensor = controller?.description.sensorOrientation ?? 0;
      switch (sensor) {
        case 0:
          rotation = InputImageRotation.rotation0deg;
          break;
        case 90:
          rotation = InputImageRotation.rotation90deg;
          break;
        case 180:
          rotation = InputImageRotation.rotation180deg;
          break;
        case 270:
          rotation = InputImageRotation.rotation270deg;
          break;
        default:
          rotation = InputImageRotation.rotation0deg;
      }
    } catch (_) {}

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      bytesPerRow: image.planes[0].bytesPerRow,
      format: format,
    );

    return InputImage.fromBytes(bytes: allBytes, metadata: metadata);
  }
}
