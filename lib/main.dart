import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MainWidget());

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: ChatList(),
        // bottomNavigationBar: BottomBar(),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                child: DrawerHeader(
                    child: Center(
                        child: Container(
                      color: Colors.black38,
                      padding: EdgeInsets.all(30.0),
                      child: Image.network(
                          'https://github.com/cerebro-iiitv/cerebro-web/blob/dev/public/fest-logo.png?raw=true'),
                    )),
                    margin: EdgeInsets.all(0.0),
                    padding: EdgeInsets.all(0.0)),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
              ),
              ListTile(
                leading: Icon(Icons.account_box),
                title: Text('Login'),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout'),
              )
            ],
          ),
        ),
      ),
      theme: ThemeData.dark(),
    );
  }
}

class ChatList extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final msgController = TextEditingController();
  final scrollController = ScrollController();

  void _sendNewMsg(String msg) {
    var instance = Firestore.instance;
    CollectionReference ref = instance.collection('chat_133');
    ref.add({'author': 'Aashu', 'title': '$msg'});
    msgController.clear();
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
          child: TextFormField(
            validator: (String text) {
              if (text.isEmpty) {
                return 'What you tryin\' to send?';
              }
            },
            controller: msgController,
            decoration: InputDecoration(
                suffix: IconButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _sendNewMsg(msgController.text);
                }
              },
              icon: Icon(Icons.send),
            )),
          ),
        )
      ],
    );
  }
}
