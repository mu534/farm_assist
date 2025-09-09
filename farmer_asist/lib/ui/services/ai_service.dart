class AIService {
  Future<String> predictPlantDisease(String imagePath) async {
    // TODO: Implement actual AI prediction logic.
    // For now, return a dummy result after a short delay.
    await Future.delayed(const Duration(seconds: 2));
    return 'Healthy';
  }
}
