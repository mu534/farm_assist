import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:farmer_asist/ui/models/plant_disease_model.dart';

/// AIService simulates plant disease detection.
/// In production, connect this to your ML model or backend API.
class AIService {
  /// Analyze image and return PlantDiseaseModel
  Future<PlantDiseaseModel> analyzeImage(File image) async {
    try {
      // 🔹 Simulate API/ML model processing delay
      await Future.delayed(const Duration(seconds: 2));

      if (kDebugMode) {
        print("Analyzing image: ${image.path}");
      }

      // Mocked disease detection logic
      final diseaseDetected = _mockDiseaseDetection();

      return PlantDiseaseModel(
        diseaseName: diseaseDetected['disease']!,
        recommendation: diseaseDetected['recommendation']!,
        confidence: double.parse(diseaseDetected['confidence']!),
      );
    } catch (e) {
      debugPrint("AIService Error: $e");
      throw Exception("Failed to analyze image");
    }
  }

  /// Mock disease detection (replace with real AI model)
  Map<String, String> _mockDiseaseDetection() {
    final diseases = [
      {
        "disease": "Leaf Blight",
        "recommendation":
            "Apply copper-based fungicides and avoid overhead watering.",
        "confidence": "0.92",
      },
      {
        "disease": "Powdery Mildew",
        "recommendation": "Use sulfur sprays and improve air circulation.",
        "confidence": "0.88",
      },
      {
        "disease": "Rust",
        "recommendation": "Remove infected leaves and apply fungicides.",
        "confidence": "0.85",
      },
      {
        "disease": "Healthy",
        "recommendation": "No treatment needed. Maintain proper care.",
        "confidence": "0.95",
      },
    ];

    diseases.shuffle();
    return diseases.first;
  }
}
