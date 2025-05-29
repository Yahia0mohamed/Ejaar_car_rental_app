class Car {
  String? id;
  final String carType;
  final String carModel;
  final double hourlyRate;
  final List<String> imageBase64s;
  final String plateCharacters;
  final String plateNumbers;
  final double latitude;
  final double longitude;

  Car({
    this.id,
    required this.carType,
    required this.carModel,
    required this.hourlyRate,
    required this.imageBase64s,
    required this.plateCharacters,
    required this.plateNumbers,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'carType': carType,
      'carModel': carModel,
      'hourlyRate': hourlyRate,
      'imageBase64s': imageBase64s,
      'plateCharacters': plateCharacters,
      'plateNumbers': plateNumbers,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map, String documentId) {
    return Car(
      id: documentId,
      carType: map['carType'] ?? '',
      carModel: map['carModel'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      imageBase64s: List<String>.from(map['imageBase64s'] ?? []),
      plateCharacters: map['plateCharacters'] ?? '',
      plateNumbers: map['plateNumbers'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }
}
