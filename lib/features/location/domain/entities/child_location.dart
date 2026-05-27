import 'package:equatable/equatable.dart';

class ChildLocation extends Equatable {
  final int childId;
  final String childName;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String timestamp;

  const ChildLocation({
    required this.childId,
    required this.childName,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  @override
  List<Object> get props => [childId, latitude, longitude, timestamp];
}
