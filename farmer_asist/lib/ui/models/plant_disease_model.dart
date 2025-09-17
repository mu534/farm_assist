class PlantDiseaseModel {
  final String plantName;
  final String commonNames;
  final String diseaseName;
  final double confidence;
  final String recommendation;

  // Constructor with default values
  PlantDiseaseModel({
    this.plantName = 'Unknown Plant',
    this.commonNames = '',
    this.diseaseName = 'Unknown',
    this.confidence = 0.0,
    this.recommendation = 'No recommendation available',
  });

  // Factory method to create from API JSON if needed
  factory PlantDiseaseModel.fromJson(Map<String, dynamic> json) {
    final plant = json['plant'] ?? {};
    final health = json['health'] ?? {};
    final disease = health['disease'] ?? json['disease'] ?? {};

    return PlantDiseaseModel(
      plantName: plant['scientific_name'] ?? json['name'] ?? 'Unknown Plant',
      commonNames: (plant['common_names'] as List?)?.join(', ') ?? '',
      diseaseName: disease['name'] ?? json['name'] ?? 'Unknown',
      confidence: (disease['probability'] ?? json['probability'] ?? 0).toDouble(),
      recommendation: disease['treatment'] ?? 'No recommendation available',
    );
  }
}
