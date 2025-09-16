import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_disease_model.dart';

class AIService {
  final String apiUrl = "https://api.plant.id/v3/identify";
  final String apiKey = "0C8yt3gUzHdjeRF1pLG24NL2qRDo8KaifNuL3M1VflKtIlBq3t";

  /// Send image to Plant.id API and return PlantDiseaseModel
  Future<PlantDiseaseModel> analyzeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final payload = jsonEncode({
        "images": [base64Image],
        "modifiers": ["similar_images"],
        "plant_language": "en",
        "disease_details": ["common_names", "description", "treatment"],
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
        body: payload,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'API Error: ${response.statusCode}\nResponse: ${response.body}',
        );
      }

      final data = json.decode(response.body);

      // Parse the top disease prediction
      if (data['suggestions'] == null || data['suggestions'].isEmpty) {
        return PlantDiseaseModel(
          diseaseName: 'Unknown',
          confidence: 0,
          recommendation: 'No recommendation available',
        );
      }

      final top = data['suggestions'][0];

      return PlantDiseaseModel(
        diseaseName: top['plant_name'] ?? top['disease'] ?? 'Unknown',
        confidence: (top['probability'] ?? 0).toDouble(),
        recommendation:
            top['disease']?['treatment'] ?? 'Check plant care guide',
      );
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
}
