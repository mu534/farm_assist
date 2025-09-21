import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  DateTime? _lastAnalyzedAt;

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
        _lastAnalyzedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to analyze image. Please try again.\n$e';
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(DateTime? ts) {
    if (ts == null) return '';
    final time = TimeOfDay.fromDateTime(ts);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${ts.year}-${two(ts.month)}-${two(ts.day)}  ${two(time.hour)}:${two(time.minute)}';
  }

  Color _confidenceColor(double c) {
    if (c >= 0.8) return Colors.green;
    if (c >= 0.6) return Colors.lightGreen;
    if (c >= 0.4) return Colors.amber;
    if (c >= 0.2) return Colors.orange;
    return Colors.redAccent;
  }

  Future<void> _copyToClipboard(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
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
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _analyzeImage,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Analysis'),
          ),
        ],
      );
    }

    // Show actual result
    final confidence = _result?.confidence ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header and quick meta
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Disease Detected', style: AppTextStyles.heading2),
                  const SizedBox(height: 6),
                  Text(
                    _result?.diseaseName ?? 'Unknown',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.primaryIndigo),
                  ),
                ],
              ),
            ),
            if (_lastAnalyzedAt != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(_formatTimestamp(_lastAnalyzedAt), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Confidence bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Confidence', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('${(confidence * 100).toStringAsFixed(1)}%'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: confidence.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  color: _confidenceColor(confidence),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recommendation with copy
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text('Recommendation', style: AppTextStyles.heading2)),
            IconButton(
              tooltip: 'Copy disease name',
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard('Disease', _result?.diseaseName ?? 'Unknown'),
            ),
            IconButton(
              tooltip: 'Copy recommendation',
              icon: const Icon(Icons.content_paste, size: 20),
              onPressed: () => _copyToClipboard('Recommendation', _result?.recommendation ?? 'No recommendation'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            _result?.recommendation ?? 'No recommendation',
            style: AppTextStyles.bodyText,
          ),
        ),
        const SizedBox(height: 16),

        // Quick actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Re-analyze'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard('Summary',
                    'Disease: ${_result?.diseaseName ?? 'Unknown'}\nConfidence: ${(confidence * 100).toStringAsFixed(1)}%\nRecommendation: ${_result?.recommendation ?? 'No recommendation'}'),
                icon: const Icon(Icons.share),
                label: const Text('Copy summary'),
              ),
            ),
          ],
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
