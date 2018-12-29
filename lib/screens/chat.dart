import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
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
  @override
  initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  final curUser = "User";

  void _sendNewMsg(String msg) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.add({'author': '$curUser', 'title': '$msg'});
    msgController.clear();
    scrollController.jumpTo(scrollController.position.maxScrollExtent + 54);
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
                        mainAxisAlignment: document['author'] == curUser
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
                                color: document['author'] == curUser
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
                                Text(document['title']),
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
