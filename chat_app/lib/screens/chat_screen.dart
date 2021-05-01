import 'dart:async';
import 'dart:developer';

import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/screens/call_video_screen.dart';
import 'package:chat_app/screens/incoming_call_screen.dart';
import 'package:chat_app/widgets/chat/messages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  // Socket ref
  Socket _socket;

  // FCM
  FirebaseMessaging fcm = FirebaseMessaging.instance;

  Future<void> _sendMessage() async {}

  void _onScroll() {
    print(_scrollController.position.maxScrollExtent);
  }

  void _onCallVideo() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CallVideoScreen(),
    ));
  }

  void _handleFCM() {
    FirebaseMessaging.onMessage.listen((message) {
      log(message.notification.title, name: 'notification');
      log(message.notification.body, name: 'notification');
      log(message.data.toString(), name: 'notification');
      Navigator.of(context).pushNamed(
        IncomingCallScreen.routeName,
        arguments: message.data['callerId'],
      );
    });
  }

  void _updateFirebaseToken() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final tokenId = await fcm.getToken();
    log(tokenId, name: 'firebase token');

    await auth.updateFirebaseToken(tokenId);
  }

  @override
  void initState() {
    super.initState();
    _handleFCM();
    _updateFirebaseToken();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // dispose socket
    if (_socket != null) {
      _socket.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Messages(
              messages: [],
              controller: _scrollController,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Send Message ...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _textController.text.isEmpty ? Colors.black38 : Colors.pink,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getAppBar() {
    return AppBar(
      title: Text('Flutter Chat'),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam),
          onPressed: _onCallVideo,
        )
      ],
    );
  }
}
