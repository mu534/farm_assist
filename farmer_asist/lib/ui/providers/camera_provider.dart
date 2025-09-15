import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:farmer_asist/ui/services/ai_service.dart';

class CameraProvider extends ChangeNotifier {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;

  // Leaf detection data
  Rect? leafBoundingBox;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isTakingPicture => _isTakingPicture;

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    _isInitialized = true;
    notifyListeners();

    // Start leaf detection stream
    _startImageStream();
  }

  Future<void> _startImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    _controller!.startImageStream((CameraImage image) async {
      if (_isTakingPicture) return;

      // Process image to detect leaf
      Rect? detectedLeaf = await _detectLeaf(image);
      if (detectedLeaf != null) {
        leafBoundingBox = detectedLeaf;
        notifyListeners();
      }
    });
  }

  /// Dummy leaf detection using AIService
  Future<Rect?> _detectLeaf(CameraImage image) async {
    // Convert CameraImage to File or bytes for AIService
    // For demo purposes, we return a centered bounding box
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    return Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: width / 3,
      height: height / 3,
    );
  }

  Future<File?> takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) return null;

    try {
      _isTakingPicture = true;
      notifyListeners();

      final XFile file = await _controller!.takePicture();

      // Crop to detected leaf bounding box if available
      final croppedFile = await _cropToLeaf(file);

      return croppedFile;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    } finally {
      _isTakingPicture = false;
      notifyListeners();
    }
  }

  Future<File> _cropToLeaf(XFile file) async {
    if (leafBoundingBox == null) return File(file.path);

    final bytes = await file.readAsBytes();
    img.Image? capturedImage = img.decodeImage(bytes);
    if (capturedImage == null) return File(file.path);

    final cropRect = leafBoundingBox!;
    final cropped = img.copyCrop(
      capturedImage,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );

    final croppedBytes = img.encodeJpg(cropped);
    final croppedFile = File('${file.path}_leaf.jpg');
    await croppedFile.writeAsBytes(croppedBytes);

    return croppedFile;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
