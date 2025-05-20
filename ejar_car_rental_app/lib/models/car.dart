class Car {
  String? id;
  final String carType;
  final String carModel;
  final double hourlyRate;
  final List<String> imageBase64s;

  Car({
    this.id,
    required this.carType,
    required this.carModel,
    required this.hourlyRate,
    required this.imageBase64s,
  });

  Map<String, dynamic> toMap() {
    return {
      'carType': carType,
      'carModel': carModel,
      'hourlyRate': hourlyRate,
      'imageBase64s': imageBase64s,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map, String documentId) {
    return Car(
      id: documentId,
      carType: map['carType'] ?? '',
      carModel: map['carModel'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0).toDouble(),
      imageBase64s: List<String>.from(map['imageBase64s'] ?? []),
    );
  }
}
