import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/utils/call_video_socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum SignalingState {
  ConnectionOpen,
  ConnectionError,
  ConnectionClosed,
}

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateConnected,
  CallStateReject,
  CallStateBye,
  CallStateDisconnected,
}

typedef void StreamStateCallback(MediaStream stream);
typedef void CallStateCallback(CallState state);

class Signaling {
  final bool isCaller;
  final String userId;
  final String otherId;
  final String token;

  Signaling({
    @required this.userId,
    @required this.otherId,
    @required this.token,
    @required this.isCaller,
  });

  // Fields
  RTCPeerConnection _peerConnection;
  MediaStream _localStream;

  get localStream => _localStream;
  MediaStream _remoteStream;
  List<RTCIceCandidate> _candidates = [];

  CallVideoSocket _socket;

  // Callback
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  CallStateCallback onCallStateChanged;

  connect() async {
    // Create Peer Connection
    await _createPeerConnection();

    // Create socket
    _socket = CallVideoSocket(token);
    _onSocketMessage();
  }

  startCallVideo() async {
    await _socket.startCallVideo(otherId);
  }

  switchEnableVideo(bool enabled) {
    if (enabled) {
      _peerConnection.addStream(_remoteStream);
    } else {
      _peerConnection.removeStream(_remoteStream);
    }
  }

  switchCamera() {
    Helper.switchCamera(_localStream?.getVideoTracks()[0]);
  }

  muteMic(bool enabled) {
    _localStream.getAudioTracks()[0].enabled = enabled;
  }

  close() {
    _socket?.dispose();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
  }

  _onSocketMessage() {
    _socket.onReceivedOffer = _onReceivedOffer;
    _socket.onReceivedAnswer = _onReceivedAnswer;
    _socket.onReceivedCandidate = _onReceivedCandidate;
    _socket.onReceiverOnline = _onReceiverOnline;
    _socket.onSocketConnected = () {
      if (!isCaller) _socket.joinFromNotify(otherId);
      if (isCaller) _socket.startCallVideo(otherId);
    };
    _socket.onPeerLeftRoom = () {
      // TODO: handle leave room!
    };
  }

  _onReceivedOffer(String offer, String callerId) async {
    log(offer, name: 'socketIO');
    await _setRemoteDescription(offer);
    await _createAnswer();
  }

  _onReceivedAnswer(String answer, bool isAccepted) async {
    log(answer, name: 'socketIO');
    await _setRemoteDescription(answer);
  }

  _onReceivedCandidate(String candidate) async {
    log(candidate, name: 'socketIO');
    await _setCandidate(candidate);
  }

  _onReceiverOnline() async {
    log('receiver online', name: 'socketIO');
    await _createOffer();
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '20',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    return stream;
  }

  Future<void> _createPeerConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    };

    final Map<String, dynamic> offerSDPConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    _localStream = await _getUserMedia();
    onLocalStream?.call(_localStream);

    // Create peer connection
    final pc = await createPeerConnection(configuration, offerSDPConstraints);

    await pc.addStream(_localStream);

    pc.onIceCandidate = (iceCandidate) {
      _candidates.add(iceCandidate);
      _sendCandidate(iceCandidate);
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      _remoteStream = stream;
      print("onAddStream");
      onAddRemoteStream?.call(stream);
    };

    this._peerConnection = pc;
  }

  Future<void> _createOffer() async {
    var desc = await _peerConnection.createOffer({'OfferToReceiveVideo': 1});
    _socket.sendOffer(desc.sdp);
    await _peerConnection.setLocalDescription(desc);
  }

  Future<void> _createAnswer() async {
    var desc = await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    _socket.sendAnswer(desc.sdp, otherId, true);
    await _peerConnection.setLocalDescription(desc);
  }

  Future<void> _setRemoteDescription(String sdp) async {
    var remoteDesc = RTCSessionDescription(sdp, isCaller ? 'answer' : 'offer');
    await _peerConnection.setRemoteDescription(remoteDesc);
  }

  Future<void> _setCandidate(String candidate) async {
    Map<String, dynamic> candidateData = json.decode(candidate);

    final iceCandidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );

    await _peerConnection.addCandidate(iceCandidate);
  }

  void _sendCandidate(RTCIceCandidate iceCandidate) {
    final candidateData = {
      'candidate': iceCandidate.candidate,
      'sdpMid': iceCandidate.sdpMid,
      'sdpMLineIndex': iceCandidate.sdpMlineIndex,
    };

    final candidate = json.encode(candidateData);
    _socket.sendCandidate(candidate);
  }
}
