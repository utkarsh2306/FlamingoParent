import '../../domain/entities/child_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource dataSource;
  LocationRepositoryImpl(this.dataSource);

  @override
  Stream<ChildLocation> watchChildLocation() => dataSource.watch();
}
