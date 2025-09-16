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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final file = File(widget.imagePath!);
      final analysis = await _aiService.analyzeImage(file);

      if (!mounted) return;
      setState(() {
        _result = analysis;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Failed to analyze image. Please try again.";
        _isLoading = false;
      });
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _analyzeImage,
                    child: const Text('Retry Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentEmerald,
                    ),
                  ),
                ],
              ),
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

                  // Recommendation
                  Text('Recommendation:', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(_result!.recommendation, style: AppTextStyles.bodyText),
                  const SizedBox(height: 16),

                  // Confidence with colored bar
                  Text('Confidence:', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(
                              _result!.confidence,
                            ).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: _result!.confidence,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(_result!.confidence),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_result!.confidence * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Re-analyze button if image available
                  if (widget.imagePath != null)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _analyzeImage,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Re-analyze Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentEmerald,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
