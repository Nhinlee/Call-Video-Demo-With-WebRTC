import 'package:chat_app/screens/call_video_screen.dart';
import 'package:flutter/material.dart';

class IncomingCallScreen extends StatelessWidget {
  static const routeName = 'incoming-call-screen';

  final String callerId;

  const IncomingCallScreen({Key key, @required this.callerId}) : super(key: key);

  void _acceptCall(BuildContext context) {
    Navigator.of(context).popAndPushNamed(
      CallVideoScreen.routeName,
      arguments: {
        'isAnswer': true,
        'callerId': callerId,
      },
    );
  }

  void _rejectCall(BuildContext context) {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 80,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () => _rejectCall(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  primary: Colors.blue,
                  padding: EdgeInsets.all(16),
                ),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                ),
                onPressed: () => _acceptCall(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
