import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:farmer_asist/ui/models/plant_disease_model.dart';

class AIService {
  final String apiUrl =
      "https://your-ai-api.com/analyze"; // replace with endpoint

  Future<PlantDiseaseModel?> analyzeImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      if (response.statusCode != 200) return null;

      final resBody = await response.stream.bytesToString();
      final jsonData = json.decode(resBody);

      return PlantDiseaseModel(
        diseaseName: jsonData['disease_name'],
        confidence: (jsonData['confidence'] as num).toDouble(),
        recommendation:
            jsonData['recommendation'] ?? 'Check plant health guide',
      );
    } catch (e) {
      print('API error: $e');
      return null;
    }
  }
}
