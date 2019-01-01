import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:gdg_gnr/screens/chat.dart';
import 'package:gdg_gnr/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras;
Future<Null> main() async {
  cameras = await availableCameras();
  runApp(MainWidget());
}

class MainWidget extends StatefulWidget {
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final String _kUserPref = "UserPref";
  Widget _routingWidget = LoginPage(cameras);

  Future<Null> getSharedPref() async {
    final SharedPreferences _localPref = await SharedPreferences.getInstance();
    String userProfile = _localPref.getString(_kUserPref);
    if (userProfile != null) {
      Auth().setCurrentUser(User.fromMap(json.decode(userProfile)));
      setState(() {
        _routingWidget = ChatList(cameras);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _routingWidget,
      ),
      theme: ThemeData.dark(),
    );
  }
}
