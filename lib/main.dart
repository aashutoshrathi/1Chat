import 'package:flutter/material.dart';
import 'package:gdg_gnr/components/drawer.dart';
import 'package:gdg_gnr/screens/chat.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MainWidget());

class MainWidget extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
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
        drawer: CustomDrawer(),
      ),
      theme: ThemeData.dark(),
    );
  }
}
