import '../entities/child_location.dart';
import '../repositories/location_repository.dart';

class WatchChildLocationUseCase {
  final LocationRepository repository;
  WatchChildLocationUseCase(this.repository);
  Stream<ChildLocation> call() => repository.watchChildLocation();
}
