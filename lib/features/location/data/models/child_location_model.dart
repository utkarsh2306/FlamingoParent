import '../../domain/entities/child_location.dart';

class ChildLocationModel extends ChildLocation {
  const ChildLocationModel({
    required super.childId,
    required super.childName,
    required super.latitude,
    required super.longitude,
    required super.accuracy,
    required super.timestamp,
  });

  factory ChildLocationModel.fromMap(Map<String, dynamic> m) {
    return ChildLocationModel(
      childId: m['childId'] as int? ?? 0,
      childName: m['childName'] as String? ?? 'Child',
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
      accuracy: (m['accuracy'] as num?)?.toDouble() ?? 0,
      timestamp: m['timestamp'] as String? ?? '',
    );
  }
}
