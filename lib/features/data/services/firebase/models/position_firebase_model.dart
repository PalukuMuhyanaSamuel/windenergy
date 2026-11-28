import 'package:windenergy/features/domain/entities/position.dart';

class PositionFirebaseModel extends Position {
  const PositionFirebaseModel({super.latitude, super.longitude});

  factory PositionFirebaseModel.fromMap({required Map<String, dynamic> map}) {
    return PositionFirebaseModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}