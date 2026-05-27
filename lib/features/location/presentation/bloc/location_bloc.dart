import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/child_location.dart';
import '../../domain/usecases/watch_child_location_usecase.dart';

// Events
abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override List<Object> get props => [];
}
class StartWatchingLocation extends LocationEvent { const StartWatchingLocation(); }
class StopWatchingLocation  extends LocationEvent { const StopWatchingLocation(); }

// States
abstract class LocationState extends Equatable {
  const LocationState();
  @override List<Object?> get props => [];
}
class LocationInitial  extends LocationState { const LocationInitial(); }
class LocationLoading  extends LocationState { const LocationLoading(); }
class LocationUpdated  extends LocationState {
  final ChildLocation location;
  const LocationUpdated(this.location);
  @override List<Object?> get props => [location];
}
class LocationOffline  extends LocationState { const LocationOffline(); }
class LocationError    extends LocationState {
  final String message;
  const LocationError(this.message);
  @override List<Object?> get props => [message];
}

// Bloc
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final WatchChildLocationUseCase _usecase;

  LocationBloc(this._usecase) : super(const LocationInitial()) {
    on<StartWatchingLocation>(_onStart);
    on<StopWatchingLocation>(_onStop);
  }

  Future<void> _onStart(StartWatchingLocation e, Emitter<LocationState> emit) async {
    emit(const LocationLoading());
    await emit.forEach(
      _usecase(),
      onData: (loc) => LocationUpdated(loc),
      onError: (e, _) => LocationError(e.toString()),
    );
  }

  Future<void> _onStop(StopWatchingLocation e, Emitter<LocationState> emit) async {
    emit(const LocationInitial());
  }
}
