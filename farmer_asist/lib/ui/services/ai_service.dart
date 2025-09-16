import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_disease_model.dart';

class AIService {
  final String apiUrl = "https://your-ai-api.com/analyze";
  final String apiKey = "rf_SjcOwyYqHMb43Dtl7HliJr5w0Y62";

  /// Send image to AI API and return PlantDiseaseModel
  Future<PlantDiseaseModel> analyzeImage(File imageFile) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.headers['Authorization'] =
        'Bearer $apiKey'; // include API key in headers
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to analyze image: ${response.statusCode}');
    }

    final responseBody = await response.stream.bytesToString();
    final data = json.decode(responseBody);

    // Map the API response to PlantDiseaseModel
    return PlantDiseaseModel(
      diseaseName: data['disease_name'] ?? 'Unknown',
      recommendation: data['recommendation'] ?? 'No recommendation',
      confidence: (data['confidence'] ?? 0).toDouble(),
    );
  }
}
