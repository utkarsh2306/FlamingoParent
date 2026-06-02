import 'package:get_it/get_it.dart';
import 'socket_service.dart';
import '../../features/location/data/datasources/location_remote_datasource.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/watch_child_location_usecase.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/sound_around/data/datasources/sound_around_datasource.dart';
import '../../features/sound_around/data/repositories/sound_around_repository_impl.dart';
import '../../features/sound_around/domain/repositories/sound_around_repository.dart';
import '../../features/sound_around/domain/usecases/toggle_sound_around_usecase.dart';
import '../../features/sound_around/presentation/bloc/sound_around_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<SocketService>(() => SocketService());

  sl.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(sl()));
  sl.registerLazySingleton(() => WatchChildLocationUseCase(sl()));
  sl.registerFactory(() => LocationBloc(sl()));

  sl.registerLazySingleton<SoundAroundDataSource>(
      () => SoundAroundDataSourceImpl(sl()));
  sl.registerLazySingleton<SoundAroundRepository>(
      () => SoundAroundRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ToggleSoundAroundUseCase(sl()));
  sl.registerFactory(() => SoundAroundBloc(sl()));
}
