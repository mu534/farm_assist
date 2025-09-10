import 'dart:io';
import 'package:flutter/material.dart';
import 'package:farmer_asist/core/themes.dart';
import 'package:farmer_asist/ui/models/plant_disease_model.dart';
import 'package:farmer_asist/ui/services/ai_service.dart';

class ResultScreen extends StatefulWidget {
  final String? imagePath;
  final PlantDiseaseModel? result;

  const ResultScreen({super.key, this.imagePath, this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AIService _aiService = AIService();
  PlantDiseaseModel? _result;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.result != null) {
      // Use precomputed result
      _result = widget.result;
      _isLoading = false;
    } else if (widget.imagePath != null) {
      _analyzeImage();
    } else {
      _error = "No image or result provided";
      _isLoading = false;
    }
  }

  Future<void> _analyzeImage() async {
    try {
      final file = File(widget.imagePath!);
      final analysis = await _aiService.analyzeImage(file);

      if (!mounted) return;
      setState(() {
        _result = analysis; // ✅ this is already PlantDiseaseModel
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
        title: const Text('Plant Disease Result'),
        backgroundColor: AppColors.backgroundLight,
        elevation: 2,
        iconTheme: const IconThemeData(color: AppColors.primaryIndigo),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentEmerald),
            )
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : _result == null
          ? const Center(child: Text('No result found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview
                  if (widget.imagePath != null)
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentEmerald,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Disease Info
                  Text('Disease Detected:', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    _result!.diseaseName,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Recommendation:', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(_result!.recommendation, style: AppTextStyles.bodyText),
                  const SizedBox(height: 16),

                  Text(
                    'Confidence: ${(100 * _result!.confidence).toStringAsFixed(1)}%',
                    style: AppTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
