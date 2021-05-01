import 'dart:developer';

import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/widgets/chat/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Messages extends StatelessWidget {
  final List<String> messages;
  final ScrollController controller;

  const Messages({Key key, @required this.messages, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.white),
      child: Container(),
    );
  }
}
