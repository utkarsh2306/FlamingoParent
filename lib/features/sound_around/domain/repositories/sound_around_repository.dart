// domain/repositories/sound_around_repository.dart
abstract class SoundAroundRepository {
  Future<void> activate(int childId);
  Future<void> deactivate(int childId, int sessionId);
}
