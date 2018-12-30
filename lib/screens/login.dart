import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:gdg_gnr/screens/chat.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  initState() {
    super.initState();
  }

  Future<void> _handleSignIn() async {
    FirebaseUser user = await Auth().signIn();
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ChatList();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          OutlineButton(
            borderSide: BorderSide(color: Colors.green),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text('Login with Google'),
            onPressed: () => _handleSignIn(),
          ),
        ],
      ),
    );
  }
}
