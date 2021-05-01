import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart';

// video call

class CallVideoSocket {
  static const String CLIENT_MAKE_CALL = 'client_make_call';
  static const String CLIENT_JOIN_CALL_FROM_NOTI = 'client_join_call_from_noti';
  static const String CLIENT_SEND_OFFER = 'client_send_offer';
  static const String CLIENT_SEND_ANSWER = 'client_answer';
  static const String CLIENT_SEND_CANDIDATE = 'client_candidate';
  static const String CLIENT_LEAVE_VIDEO_CALL = 'client_leave_call';

  static const String SEVER_SEND_RECEIVER_ONLINE = 'server_send_receiver_online';
  static const String SERVER_SEND_OFFER = 'server_send_offer';
  static const String SERVER_SEND_ANSWER = 'server_send_answer';
  static const String SERVER_SEND_CANDIDATE = 'server_send_candidate';
  static const String SERVER_LEAVE_VIDEO_CALL = 'server_leave_video_call';

  Function onSocketConnected;
  Function(String offer, String callerId) onReceivedOffer;
  Function(String answer, bool isAccepted) onReceivedAnswer;
  Function(String candidate) onReceivedCandidate;
  Function onReceiverOnline;
  Function onPeerLeftRoom;

  //final String host = 'http://10.0.2.2:8080/videocall';
  final String host = 'https://togetherapis.herokuapp.com/videocall';
  final String token;
  Socket _socket;

  CallVideoSocket(this.token) {
    final _socketOption = OptionBuilder()
        .setTransports(['websocket'])
        .setQuery({
          'token': token,
        })
        .disableAutoConnect()
        .build();
    _socket = io(host, _socketOption);
    _socket.connect();

    _socket.onConnect((data) {
      print('socket connected');

      _socket.on(
        SEVER_SEND_RECEIVER_ONLINE,
        (data) => onReceiverOnline?.call(),
      );

      _socket.on(
        SERVER_SEND_OFFER,
        (data) => onReceivedOffer?.call(
          data['offer'],
          data['callerId'],
        ),
      );

      _socket.on(
        SERVER_SEND_ANSWER,
        (data) => onReceivedAnswer?.call(
          data['answer'],
          data['Isaccepted'],
        ),
      );

      _socket.on(
        SERVER_SEND_CANDIDATE,
        (data) => onReceivedCandidate?.call(
          data['candidate'],
        ),
      );

      onSocketConnected?.call();
    });
  }

  startCallVideo(String receiverId) {
    _socket?.emitWithAck(
      CLIENT_MAKE_CALL,
      {
        'receiverId': receiverId,
      },
      ack: (res) {
        log(res, name: 'socketIO');
      },
    );
  }

  joinFromNotify(String callerId) {
    log(callerId, name: 'socketIO');
    _socket?.emitWithAck(
      CLIENT_JOIN_CALL_FROM_NOTI,
      {
        'callerId': callerId,
      },
      ack: (res) {
        log(res, name: 'socketIO');
      },
    );
  }

  sendOffer(String offer) {
    _socket?.emitWithAck(
      CLIENT_SEND_OFFER,
      {
        'offer': offer,
      },
      ack: (res) {
        log(res, name: 'socketIO');
      },
    );
  }

  sendAnswer(String answer, String callerId, bool isAccepted) {
    _socket?.emitWithAck(
      CLIENT_SEND_ANSWER,
      {
        'callerId': callerId,
        'answer': answer,
        'isaccepted ': isAccepted,
      },
      ack: (res) {
        log(res, name: 'socketIO');
      },
    );
  }

  sendCandidate(String candidate) {
    _socket?.emit(CLIENT_SEND_CANDIDATE, {
      'candidate': candidate,
    });
  }

  sendLeaveVideoCall() {
    _socket?.emit(CLIENT_LEAVE_VIDEO_CALL);
  }

  dispose() {
    _socket.dispose();
  }
}
