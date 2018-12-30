import 'package:firebase_auth/firebase_auth.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class Auth {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();
  static String _kUserPref = "UserPref";
  static User _curUser;

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("signed in " + user.displayName);
    assert(user != null);
    User _loggedInUser = User.fromFirebaseUser(user);
    print(_loggedInUser.toString());
    _curUser = _loggedInUser;

    SharedPreferences pref = await SharedPreferences.getInstance();
    final response = await pref
        .setString(_kUserPref, json.encode(_loggedInUser.toJson()))
        .then((_) {
      print('Shared Preference saved');
      return user;
    }).catchError((_) {
      print('Unable to save to sharedPreference');
      return null;
    });
    return response;
  }

  Future<void> signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(_kUserPref);
    print('User removed');
    _curUser = null;
    return _auth.signOut();
  }

  User getCurrentUser() {
    return _curUser;
  }

  void setCurrentUser(User curUser) {
    _curUser = curUser;
  }
}
