import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdg_gnr/screens/chat.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> _handleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("Signed in " + user.displayName);
    return user;
  }

  void _signOut() async {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OutlineButton(
          color: Colors.greenAccent[100],
          textColor: Colors.green,
          borderSide: BorderSide(color: Colors.green),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0)),
          child: Text(
            'Log In with Google',
            textScaleFactor: 1.5,
          ),
          onPressed: () async {
            _handleSignIn();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ChatWidget();
            }));
          },
        ),
        Container(margin: EdgeInsets.all(10.0)),
        OutlineButton(
          color: Colors.redAccent[100],
          textColor: Colors.red,
          borderSide: BorderSide(color: Colors.red),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0)),
          child: Text(
            'Sign Out',
            textScaleFactor: 1.5,
          ),
          onPressed: () async {
            _signOut();
            // Navigator.push(context, MaterialPageRoute(builder: (context) {
            //   return ChatList();
            // }));
          },
        ),
      ],
    ));
  }
}
