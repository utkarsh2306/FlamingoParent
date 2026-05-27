import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/toggle_sound_around_usecase.dart';

// Events
abstract class SoundAroundEvent extends Equatable {
  const SoundAroundEvent();
  @override List<Object> get props => [];
}
class ActivateSoundAround extends SoundAroundEvent {
  final int childId;
  const ActivateSoundAround(this.childId);
  @override List<Object> get props => [childId];
}
class DeactivateSoundAround extends SoundAroundEvent {
  final int childId;
  final int sessionId;
  const DeactivateSoundAround(this.childId, this.sessionId);
  @override List<Object> get props => [childId, sessionId];
}

// States
abstract class SoundAroundState extends Equatable {
  const SoundAroundState();
  @override List<Object?> get props => [];
}
class SoundAroundIdle extends SoundAroundState { const SoundAroundIdle(); }
class SoundAroundLoading extends SoundAroundState { const SoundAroundLoading(); }
class SoundAroundActive extends SoundAroundState {
  final int childId;
  final int sessionId;
  const SoundAroundActive(this.childId, this.sessionId);
  @override List<Object?> get props => [childId, sessionId];
}
class SoundAroundError extends SoundAroundState {
  final String message;
  const SoundAroundError(this.message);
  @override List<Object?> get props => [message];
}

// Bloc
class SoundAroundBloc extends Bloc<SoundAroundEvent, SoundAroundState> {
  final ToggleSoundAroundUseCase _usecase;

  SoundAroundBloc(this._usecase) : super(const SoundAroundIdle()) {
    on<ActivateSoundAround>(_onActivate);
    on<DeactivateSoundAround>(_onDeactivate);
  }

  Future<void> _onActivate(ActivateSoundAround e, Emitter<SoundAroundState> emit) async {
    emit(const SoundAroundLoading());
    try {
      await _usecase.activate(e.childId);
      // sessionId will come via socket started event
      // For simplicity, use timestamp as temp sessionId
      emit(SoundAroundActive(e.childId, DateTime.now().millisecondsSinceEpoch));
    } catch (err) {
      emit(SoundAroundError(err.toString()));
    }
  }

  Future<void> _onDeactivate(DeactivateSoundAround e, Emitter<SoundAroundState> emit) async {
    try {
      await _usecase.deactivate(e.childId, e.sessionId);
      emit(const SoundAroundIdle());
    } catch (err) {
      emit(SoundAroundError(err.toString()));
    }
  }
}
