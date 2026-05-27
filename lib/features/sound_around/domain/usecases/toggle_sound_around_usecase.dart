import '../repositories/sound_around_repository.dart';

class ToggleSoundAroundUseCase {
  final SoundAroundRepository repository;
  ToggleSoundAroundUseCase(this.repository);

  Future<void> activate(int childId) => repository.activate(childId);
  Future<void> deactivate(int childId, int sessionId) => repository.deactivate(childId, sessionId);
}
