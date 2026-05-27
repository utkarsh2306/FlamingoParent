import '../entities/child_location.dart';

abstract class LocationRepository {
  Stream<ChildLocation> watchChildLocation();
}
