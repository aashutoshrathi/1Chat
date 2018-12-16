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
          title: Text('Awesome Chat App'),
        ),
        body: ChatList(),
        bottomNavigationBar: BottomBar(),
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('chat_133').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return Card(
                    elevation: 2.0,
                    color: Colors.black26,
                    child: ListTile(
                      onTap: () => debugPrint(
                          "Tapped messages from ${document['title']}"),
                      leading: Icon(Icons.account_circle, size: 35),
                      title: new Text(document['title']),
                      subtitle: new Text(document['author']),
                      trailing: GestureDetector(
                        child: Icon(Icons.delete_sweep,
                            color: Colors.redAccent, size: 30),
                        onTap: () => debugPrint("Hi Baka, Don't delete it."),
                      ),
                    ));
              }).toList(),
            );
        }
      },
    );
  }
}

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(Icons.home),
          title: new Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.mail),
          title: new Text('Messages'),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person), title: Text('Profile'))
      ],
    );
  }
}
