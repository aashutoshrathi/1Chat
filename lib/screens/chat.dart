import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatList extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  void _sendNewMsg(String msg) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.add({'author': 'Aashu', 'title': '$msg'});
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
                  return new Text('Loading...');
                default:
                  return new ListView(
                    controller: scrollController,
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Container(
                          child: Row(
                        mainAxisAlignment: document['author'] == "Aashu"
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
                                color: document['author'] == "Aashu"
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
          child: Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.all(5.0),
            child: TextFormField(
              validator: (String text) {
                if (text.isEmpty) {
                  return 'What you tryin\' to send?';
                }
              },
              controller: msgController,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  hasFloatingPlaceholder: true,
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                      borderRadius: BorderRadius.circular(20.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                      borderRadius: BorderRadius.circular(20.0)),
                  filled: true,
                  fillColor: Colors.black26,
                  hintText: 'Just say it....',
                  suffix: IconButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _sendNewMsg(msgController.text);
                      }
                    },
                    icon: Icon(Icons.send),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
