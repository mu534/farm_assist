import 'dart:io';
import 'package:flutter/material.dart';
import '/core/themes.dart';
import '../models/plant_disease_model.dart';
import '../services/ai_service.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

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
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final file = File(widget.imagePath);
      final analysis = await _aiService.analyzeImage(file);

      if (!mounted) return;
      setState(() {
        _result = analysis;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to analyze image. Please try again.\n$e';
        _isLoading = false;
      });
    }
  }

  Widget _buildResultContent() {
    if (_isLoading) {
      // Skeleton placeholder while analyzing
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentEmerald,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Analyzing image...",
            style: TextStyle(fontSize: 16),
          ),
        ],
      );
    }

    if (_error != null) {
      // Display error under the image
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.error, size: 50, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    // Show actual result
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Disease Detected:', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          _result?.diseaseName ?? 'Unknown',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primaryIndigo,
          ),
        ),
        const SizedBox(height: 16),
        Text('Recommendation:', style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        Text(
          _result?.recommendation ?? 'No recommendation',
          style: AppTextStyles.bodyText,
        ),
        const SizedBox(height: 16),
        Text(
          'Confidence: ${(100 * (_result?.confidence ?? 0)).toStringAsFixed(1)}%',
          style: AppTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _analyzeImage,
            icon: const Icon(Icons.refresh, color: AppColors.primaryIndigo),
            tooltip: 'Re-analyze',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _analyzeImage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Always show the image
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
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display result / skeleton / error
              _buildResultContent(),
            ],
          ),
        ),
      ),
    );
  }
}
