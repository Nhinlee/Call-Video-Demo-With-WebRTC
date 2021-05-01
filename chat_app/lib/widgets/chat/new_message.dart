import 'dart:convert';

import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String newMessage = '';
  var _controller = TextEditingController();

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    _controller.clear();
    /*final user = FirebaseAuth.instance.currentUser;
    final userData = await  FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': newMessage,
      'createdAt' : Timestamp.now(),
      'userId' : user.uid,
      'username' : userData.data()['username'],
      'userImage' : userData.data()['image_url'],
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send Message ...',
              ),
              onChanged: (value) {
                setState(() {
                  newMessage = value;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: newMessage.isEmpty ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
