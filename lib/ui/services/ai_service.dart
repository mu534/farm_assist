import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_disease_model.dart';

class AIService {
  final String apiUrl = "https://plant.id/api/v3/identification";
  final String apiKey = "0C8yt3gUzHdjeRF1pLG24NL2qRDo8KaifNuL3M1VflKtIlBq3t";

  Future<PlantDiseaseModel> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Primary request body with object modifiers
      final body = jsonEncode({
        "images": [base64Image],
        "modifiers": {
          "classification_level": "species",
          "health": "all",
          "similar_images": true,
          "symptoms": true
        }
      });

      // Minimal fallback (if modifiers rejected)
      final bodyMinimal = jsonEncode({"images": [base64Image]});

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
        body: body,
      ).timeout(const Duration(seconds: 30));

      // Retry with minimal body if "Unknown modifier" error
      if (response.statusCode == 400 && response.body.contains('Unknown modifier')) {
        response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
          body: bodyMinimal,
        ).timeout(const Duration(seconds: 30));
      }

      // Accept 200 or 201 as valid
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('API error: ${response.statusCode} -> ${response.body}');
      }

      final data = json.decode(response.body);

      // Handle nested suggestions
      List? suggestions = data['suggestions'] as List?;
      if (suggestions != null && suggestions.isNotEmpty && suggestions[0] is List) {
        suggestions = suggestions.expand((x) => x).toList();
      }

      // Fallback to classification.suggestions
      suggestions ??= (data['result']?['classification']?['suggestions'] as List?) ?? [];

      if (suggestions.isEmpty) {
        return PlantDiseaseModel(); // Default model
      }

      final first = suggestions[0];

      // Check plant probability
      final dynamic isPlantProbabilityRaw = first['is_plant_probability'] ?? data['is_plant_probability'] ?? 1.0;
      final double isPlantProbability = isPlantProbabilityRaw is num ? isPlantProbabilityRaw.toDouble() : 1.0;
      if (isPlantProbability < 0.5) {
        return PlantDiseaseModel(
          plantName: 'No plant detected',
          commonNames: '',
          diseaseName: 'Unknown',
          confidence: 0.0,
          recommendation: 'Please capture a clear photo of a plant leaf or stem.',
        );
      }

      // Extract plant info
      final plant = first['plant'] ?? {};
      final plantName = plant['scientific_name'] ?? first['name'] ?? 'Unknown';
      final commonNames = (plant['common_names'] as List?)?.join(', ') ?? '';

      // Extract disease info
      final health = first['health'] ?? {};
      final disease = health['disease'] ?? first['disease'] ?? {};
      final diseaseName = disease['name'] ?? first['name'] ?? 'Unknown';
      final confidence = (disease['probability'] ?? first['probability'] ?? 0).toDouble();
      final treatment = disease['treatment'] ?? 'No treatment info';

      return PlantDiseaseModel(
        plantName: plantName,
        commonNames: commonNames,
        diseaseName: diseaseName,
        confidence: confidence,
        recommendation: treatment,
      );
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}
