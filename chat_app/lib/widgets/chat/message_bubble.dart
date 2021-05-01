import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final String username;
  final String imageUrl;

  const MessageBubble({
    Key key,
    this.message,
    this.isMine,
    this.username,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        /*if (!isMine)
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
            radius: 14,
          ),*/
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 20,
            maxWidth: size.width * 2 / 3,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            margin: EdgeInsets.only(top: 2, left: 16, right: 16),
            decoration: BoxDecoration(
              color: isMine ? Theme.of(context).primaryColor : Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMine ? Radius.circular(10) : Radius.circular(0),
                bottomRight: !isMine ? Radius.circular(10) : Radius.circular(0),
              ),
            ),
            child: Column(
              children: [
                /*Text(
                  username,
                  style: TextStyle(
                    color: Theme.of(context).accentTextTheme.headline6.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),*/
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
