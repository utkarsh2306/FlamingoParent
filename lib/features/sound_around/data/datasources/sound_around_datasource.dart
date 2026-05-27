import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/socket_service.dart';

abstract class SoundAroundDataSource {
  Future<void> sendActivate(int childId);
  Future<void> sendDeactivate(int childId, int sessionId);
  Future<void> startPlaying();
  Future<void> stopPlaying();
}

class SoundAroundDataSourceImpl implements SoundAroundDataSource {
  final SocketService _socket;
  final FlutterSoundPlayer _player;
  bool _playerOpen = false;
  int _lastIndex = -1;

  SoundAroundDataSourceImpl(this._socket, this._player);

  @override
  Future<void> sendActivate(int childId) async {
    _socket.emit('sound:start', {'childId': childId});
  }

  @override
  Future<void> sendDeactivate(int childId, int sessionId) async {
    _socket.emit('sound:stop', {'childId': childId, 'sessionId': sessionId});
  }

  @override
  Future<void> startPlaying() async {
    if (!_playerOpen) {
      await _player.openPlayer();
      _playerOpen = true;
    }
    _lastIndex = -1;

    _socket.on('sound:chunk_received', (data) async {
      final index = data['chunkIndex'] as int? ?? 0;
      final b64 = data['audioBase64'] as String?;
      if (b64 == null || index <= _lastIndex) return;
      _lastIndex = index;
      try {
        final bytes = base64Decode(b64);
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/flamingo_play_$index.aac');
        await f.writeAsBytes(bytes);
        if (_player.isPlaying) await _player.stopPlayer();
        await _player.startPlayer(
          fromURI: f.path,
          codec: Codec.aacADTS,
          whenFinished: () async { if (await f.exists()) await f.delete(); },
        );
      } catch (e) {
        print('❌ play chunk: $e');
      }
    });

    _socket.on('sound:child_offline', (_) => stopPlaying());
  }

  @override
  Future<void> stopPlaying() async {
    _socket.off('sound:chunk_received');
    _socket.off('sound:child_offline');
    if (_player.isPlaying) await _player.stopPlayer();
    _lastIndex = -1;
  }
}
