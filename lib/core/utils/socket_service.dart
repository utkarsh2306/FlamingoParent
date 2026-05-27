import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

class SocketService {
  static final SocketService _i = SocketService._();
  factory SocketService() => _i;
  SocketService._();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (_socket?.connected == true) return;
    _socket = IO.io(
      AppConstants.serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );
    _socket!.connect();
    _socket!.onConnect((_) => print('🦩 Socket connected'));
    _socket!.onDisconnect((_) => print('🔌 Socket disconnected'));
    _socket!.onConnectError((e) => print('❌ Socket error: $e'));
  }

  void disconnect() { _socket?.disconnect(); _socket = null; }
  void emit(String event, dynamic data) => _socket?.emit(event, data);
  void on(String event, Function(dynamic) fn) => _socket?.on(event, fn);
  void off(String event) => _socket?.off(event);
}
