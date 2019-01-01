import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gdg_gnr/components/rich_text_view.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gdg_gnr/screens/camera_screen.dart';
import 'package:gdg_gnr/screens/login.dart';
import 'package:intl/intl.dart';

class ChatList extends StatefulWidget {
  final cameras;
  ChatList(this.cameras);
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  User curUser;
  @override
  initState() {
    User user = Auth().getCurrentUser();
    if (user != null) {
      setState(() {
        curUser = user;
      });
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  void _sendNewMsg(String msg) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.add({
      'id': '${curUser.id}',
      'img': '${curUser.imgURL}',
      'author': '${curUser.name}',
      'msg': '$msg',
      'timestamp': DateTime.now()
    });
    msgController.clear();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 160,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 400),
    );
  }

  String _date(DateTime timestamp) {
    return DateFormat.jm().format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(milliseconds: 1000),
        () => scrollController.animateTo(
              scrollController.position.maxScrollExtent + 160,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 400),
            ));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('1Chat β'),
          actions: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(curUser.imgURL),
                  ),
                  onTap: () {
                    print('User Profile');
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    child: Icon(Icons.exit_to_app, size: 30.0),
                    onTap: () {
                      Auth().signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginPage(widget.cameras);
                      }));
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('chat_133').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: new Text('Loading...'));
                    default:
                      return new ListView(
                        controller: scrollController,
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return Container(
                              child: Row(
                            mainAxisAlignment: document['id'] == curUser.id
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: document['id'] == curUser.id
                                    ? SizedBox()
                                    : CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                document['img']),
                                      ),
                              ),
                              Container(
                                // All styling here only
                                constraints: BoxConstraints(
                                  maxWidth: 200.0,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                    color: document['id'] == curUser.id
                                        ? Colors.blueAccent
                                        : Colors.black,
                                    borderRadius: BorderRadius.circular(25.0)),
                                child: Column(
                                  crossAxisAlignment:
                                      document['id'] == curUser.id
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: <Widget>[
                                    document['id'] == curUser.id
                                        ? SizedBox()
                                        : Text(
                                            document['author'].split(' ')[0],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.0),
                                          ),
                                    RichTextView(text: document['msg']),
                                    Container(
                                      child: Text(_date(document['timestamp']),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 10.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ));
                        }).toList(),
                      );
                  }
                },
              ),
            ),
            Form(
                key: _formKey,
                // This thing goes to the bottom
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Material(
                    color: Colors.grey[600],
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    child: TextFormField(
                      validator: (String text) {
                        if (text.isEmpty) {
                          return 'What you tryin\' to send? :/';
                        }
                      },
                      controller: msgController,
                      decoration: InputDecoration(
                          prefixIcon: IconButton(
                            icon: Icon(Icons.camera),
                            onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return CameraApp(widget.cameras);
                                })),
                            color: Colors.white,
                            tooltip: 'Camera',
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _sendNewMsg(msgController.text);
                              }
                            },
                          ),
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          hintText: 'Type message here...'),
                    ),
                  ),
                )),
            SizedBox(
              height: 15.0,
            )
          ],
        ),
      ),
      theme: ThemeData.dark(),
    );
  }
}
