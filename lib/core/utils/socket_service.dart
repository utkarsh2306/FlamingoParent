import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

class SocketService {
  static final SocketService _i = SocketService._();
  factory SocketService() => _i;
  SocketService._();

  IO.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  final List<Function()> _onReconnectCallbacks = [];

  void onReconnect(Function() callback) {
    if (!_onReconnectCallbacks.contains(callback)) {
      _onReconnectCallbacks.add(callback);
    }
  }

  void removeReconnectCallback(Function() callback) {
    _onReconnectCallbacks.remove(callback);
  }

  void connect(String token) {
    if (_socket?.connected == true) return;
    _socket = IO.io(
      AppConstants.serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(99999)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(3000)
          .setTimeout(10000)
          .build(),
    );
    _socket!.connect();
    _socket!.onConnect((_) {
      print('🦩 Socket connected');
      for (final cb in _onReconnectCallbacks) {
        cb();
      }
    });
    _socket!.onDisconnect(
        (reason) => print('🔌 Parent socket disconnected — reason: $reason'));
    _socket!.onConnectError((e) => print('❌ Socket connect error: $e'));
    _socket!.onReconnect((_) => print('🔄 Socket reconnected'));
    _socket!.onReconnectAttempt(
        (attempt) => print('🔄 Reconnect attempt #$attempt'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void emit(String event, dynamic data) => _socket?.emit(event, data);
  void on(String event, Function(dynamic) fn) => _socket?.on(event, fn);
  void off(String event) => _socket?.off(event);
}
