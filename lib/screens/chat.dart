import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gdg_gnr/screens/login.dart';
import 'package:intl/intl.dart';

class ChatWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
          actions: <Widget>[
            Row(
              children: <Widget>[
                GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                        'https://www.atomix.com.au/media/2015/06/atomix_user31.png'),
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
                      Navigator.pop(context,
                          MaterialPageRoute(builder: (context) {
                        return LoginPage();
                      }));
                    },
                  ),
                )
              ],
            ),
          ],
        ),
        body: ChatList(),
      ),
      theme: ThemeData.dark(),
    );
  }
}

class ChatList extends StatefulWidget {
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
    ref.add({'author': '${curUser.name}', 'msg': '$msg', 'timestamp': DateTime.now()});
    msgController.clear();
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 54);
  }

  String _date(DateTime timestamp) {
    return DateFormat.jm().format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('chat_133').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        mainAxisAlignment: document['author'] == curUser.name
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            // All styling here only
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                color: document['author'] == curUser.name
                                    ? Colors.blueAccent
                                    : Colors.black,
                                borderRadius: BorderRadius.circular(25.0)),
                            child: Column(
                              children: <Widget>[
                                // Icon(Icons.account_circle),
                                Text(
                                  document['author'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                                Text(document['msg']),
                              ],
                            ),
                          ),
                          Text(_date(document['timestamp']),
                              style: TextStyle(fontSize: 10.0)),
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
                      return 'What you tryin\' to send?';
                    }
                  },
                  controller: msgController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        color: Colors.white,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _sendNewMsg(msgController.text);
                          }
                        },
                      ),
                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                      hintText: 'Type message here...'),
                ),
              ),
            )),
        SizedBox(
          height: 15.0,
        )
      ],
    );
  }
}
