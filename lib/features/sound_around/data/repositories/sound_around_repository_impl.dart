import '../../domain/repositories/sound_around_repository.dart';
import '../datasources/sound_around_datasource.dart';

class SoundAroundRepositoryImpl implements SoundAroundRepository {
  final SoundAroundDataSource dataSource;
  SoundAroundRepositoryImpl(this.dataSource);

  @override
  Future<void> activate(int childId) async {
    await dataSource.sendActivate(childId);
    await dataSource.startPlaying(childId);
  }

  @override
  Future<void> deactivate(int childId, int sessionId) async {
    await dataSource.sendDeactivate(childId, sessionId);
    await dataSource.stopPlaying(childId, sessionId);
  }
}
