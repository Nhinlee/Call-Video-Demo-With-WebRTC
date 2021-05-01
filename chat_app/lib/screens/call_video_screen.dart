import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/utils/accounts.dart';
import 'package:chat_app/utils/signaling.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CallVideoScreen extends StatefulWidget {
  static const routeName = 'call-video-screen';

  final bool isAnswer;
  final String callerId;

  const CallVideoScreen({
    Key key,
    this.isAnswer = false,
    this.callerId,
  }) : super(key: key);

  @override
  _CallVideoScreenState createState() => _CallVideoScreenState();
}

class _CallVideoScreenState extends State<CallVideoScreen> {
  // RTC video renderer
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final userIdController = TextEditingController();

  // RTC Connections
  Signaling _signaling;
  bool isEnableVideo = true;
  bool isEnableAudio = true;
  bool isFacingMode = true;

  void _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initSignaling() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (this.widget.isAnswer) {
      _signaling = Signaling(
        userId: auth.userId,
        token: auth.token,
        otherId: this.widget.callerId,
        isCaller: !this.widget.isAnswer,
      )..connect();
    } else {
      _signaling = Signaling(
        userId: auth.userId,
        token: auth.token,
        otherId: auth.userId == accounts[0]['userId']
            ? accounts[1]['userId']
            : accounts[0]['userId'],
        isCaller: !this.widget.isAnswer,
      )..connect();
    }

    _signaling.onLocalStream = (stream) {
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };

    _signaling.onAddRemoteStream = (stream) {
      print("call video success");
      setState(() {
        _remoteRenderer.srcObject = stream;
      });
    };
  }

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _initSignaling();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.close();
    super.dispose();
  }

  Future<void> _callVideo() async {
    _signaling.startCallVideo();
  }

  void _switchEnableVideo() {
    setState(() {
      isEnableVideo = !isEnableVideo;
      if (isEnableVideo) {
        _localRenderer.srcObject = _signaling.localStream;
      } else {
        _localRenderer.srcObject = null;
      }
    });

    _signaling.switchEnableVideo(isEnableVideo);
  }

  void _switchEnableAudio() {
    setState(() {
      isEnableAudio = !isEnableAudio;
      _signaling.muteMic(isEnableAudio);
    });
  }

  void _switchCamera() {
    setState(() {
      _signaling.switchCamera();
    });
  }

  void _endCall() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          getRemoteVideoRenderer(size),
          SlidingUpPanel(
            header: Container(
              height: 100,
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  getCallKitButton(
                    iconData: isEnableVideo ? Icons.videocam : Icons.videocam_off,
                    onTap: _switchEnableVideo,
                    bgColor: isEnableVideo ? Colors.orange : Colors.grey,
                  ),
                  getCallKitButton(
                    iconData: Icons.flip_camera_ios_rounded,
                    onTap: _switchCamera,
                  ),
                  getCallKitButton(
                    iconData: isEnableAudio
                        ? Icons.keyboard_voice
                        : Icons.keyboard_voice_outlined,
                    onTap: _switchEnableAudio,
                    bgColor: isEnableAudio ? Colors.orange : Colors.grey,
                  ),
                  getCallKitButton(
                    iconData: Icons.call_end,
                    bgColor: Colors.red,
                    onTap: _endCall,
                  ),
                ],
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            panel: Center(
              child: Text('This is sliding up panel'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    getLocalVideoRenderer(size),
                    SizedBox(
                      height: 120,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getRemoteVideoRenderer(Size size) {
    return Container(
      color: Colors.grey,
      child: RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
    );
  }

  Widget getLocalVideoRenderer(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: size.height / 5,
              width: size.height / 5 * 10 / 14,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: RTCVideoView(
                _localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget offerAndAnswerButton() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: _callVideo,
            child: Text('Offer'),
          ),
        ],
      );

  Widget getCallKitButton({
    IconData iconData,
    Function() onTap,
    Color bgColor = Colors.orange,
  }) =>
      ElevatedButton(
        onPressed: onTap,
        child: Icon(
          iconData,
          size: 28,
        ),
        style: ElevatedButton.styleFrom(
          primary: bgColor,
          shape: CircleBorder(),
          padding: EdgeInsets.all(16),
        ),
      );
}
