import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../../core/utils/socket_service.dart';

const String agoraAppId = 'd366a914ac334ee6aa7b8df9942b64b0';

abstract class SoundAroundDataSource {
  Future<void> sendActivate(int childId);
  Future<void> sendDeactivate(int childId, int sessionId);
  Future<void> startPlaying(int childId);
  Future<void> stopPlaying(int childId, int sessionId);
}

class SoundAroundDataSourceImpl implements SoundAroundDataSource {
  final SocketService _socket;
  RtcEngine? _engine;
  bool _engineInitialized = false;
  bool _inChannel = false;

  SoundAroundDataSourceImpl(this._socket);

  Future<void> _initEngine() async {
    if (_engineInitialized) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    await _engine!.enableAudio();
    await _engine!.disableVideo();

    // ✅ Parent is audience — never touches microphone
    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleAudience,
    );

    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    // ✅ Force speaker from the start
    await _engine!.setDefaultAudioRouteToSpeakerphone(true);

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print('🎧 Parent joined Agora channel: ${connection.channelId}');
        _inChannel = true;
      },
      onLeaveChannel: (connection, stats) {
        print('🎧 Parent left Agora channel');
        _inChannel = false;
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        print('🎙️ Child detected in channel! uid=$remoteUid');
        // ✅ Re-apply audio settings when child joins
        _engine?.muteAllRemoteAudioStreams(false);
        _engine?.setEnableSpeakerphone(true);
        _engine?.adjustPlaybackSignalVolume(100);
      },
      onUserOffline: (connection, remoteUid, reason) {
        print('📴 Child left channel uid=$remoteUid reason=$reason');
      },
      onRemoteAudioStateChanged:
          (connection, remoteUid, state, reason, elapsed) {
        print('🔊 Remote audio state=$state reason=$reason');
      },
      onAudioVolumeIndication:
          (connection, speakers, speakerNumber, totalVolume) {
        if (totalVolume > 0) print('🔊 Volume: $totalVolume');
      },
      onError: (err, msg) {
        print('❌ Agora error: $err - $msg');
      },
    ));

    _engineInitialized = true;
    print('✅ Parent Agora engine initialized');
  }

  @override
  Future<void> sendActivate(int childId) async {
    print('📤 Sending sound:start for childId=$childId');
    _socket.emit('sound:start', {'childId': childId});
  }

  @override
  Future<void> sendDeactivate(int childId, int sessionId) async {
    _socket.emit('sound:stop', {'childId': childId, 'sessionId': sessionId});
  }

  @override
  Future<void> startPlaying(int childId) async {
    await _initEngine();

    // ✅ Leave previous channel cleanly
    if (_inChannel) {
      await _engine!.leaveChannel();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final channelName = 'flamingo_$childId';
    print('🎧 Parent joining Agora channel: $channelName');

    await _engine!.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        autoSubscribeAudio: true,
        autoSubscribeVideo: false,
        publishMicrophoneTrack: false,
        publishCameraTrack: false,
      ),
    );

    // ✅ Wait for join then configure audio
    await Future.delayed(const Duration(milliseconds: 300));
    await _engine!.muteLocalAudioStream(true);
    await _engine!.muteAllRemoteAudioStreams(false);
    await _engine!.setEnableSpeakerphone(true);
    await _engine!.adjustPlaybackSignalVolume(100);

    // ✅ Monitor volume to verify audio is flowing
    await _engine!.enableAudioVolumeIndication(
      interval: 1000,
      smooth: 3,
      reportVad: true,
    );

    print('🔊 Audio configured — waiting for child audio...');
  }

  @override
  Future<void> stopPlaying(int childId, int sessionId) async {
    print('🛑 Parent leaving Agora channel');
    if (_inChannel) {
      await _engine!.leaveChannel();
      _inChannel = false;
    }
  }
}
