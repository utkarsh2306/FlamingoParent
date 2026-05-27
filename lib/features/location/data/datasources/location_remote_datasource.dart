import 'dart:async';
import '../../../../core/utils/socket_service.dart';
import '../models/child_location_model.dart';

abstract class LocationRemoteDataSource {
  Stream<ChildLocationModel> watch();
  void dispose();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final SocketService _socket;
  final _ctrl = StreamController<ChildLocationModel>.broadcast();

  LocationRemoteDataSourceImpl(this._socket) {
    _socket.on('location:received', (data) {
      try {
        _ctrl.add(ChildLocationModel.fromMap(Map<String, dynamic>.from(data)));
      } catch (e) {
        print('❌ location parse: $e');
      }
    });
  }

  @override
  Stream<ChildLocationModel> watch() => _ctrl.stream;

  @override
  void dispose() {
    _socket.off('location:received');
    _ctrl.close();
  }
}
