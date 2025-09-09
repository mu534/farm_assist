import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/services/ai_service.dart';
import 'package:farmer_asist/ui/models/plant_disease_model.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final String? detectedDisease;
  final String? recommendation;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    this.detectedDisease,
    this.recommendation,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final AIService _aiService = AIService();
  PlantDiseaseModel? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final file = File(widget.imagePath);
      final analysis = await _aiService.analyzeImage(file);

      if (!mounted) return;
      setState(() {
        _result = analysis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to analyze image. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Preview & Result"),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentEmerald, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
            ),
          ),

          // AI Result Section
          Expanded(
            flex: 3,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentEmerald,
                    ),
                  )
                : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _result == null
                ? const Center(child: Text("No result available"))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Disease Detected:",
                          style: AppTextStyles.heading2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.diseaseName,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primaryIndigo,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text("Recommendation:", style: AppTextStyles.heading2),
                        const SizedBox(height: 8),
                        Text(
                          _result!.recommendation,
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Confidence: ${(100 * _result!.confidence).toStringAsFixed(1)}%",
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
