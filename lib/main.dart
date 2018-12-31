import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gdg_gnr/models/user.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:gdg_gnr/screens/chat.dart';
import 'package:gdg_gnr/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MainWidget());

class MainWidget extends StatefulWidget {
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  final String _kUserPref = "UserPref";
  Widget _routingWidget = LoginPage();

  Future<Null> getSharedPref() async {
    final SharedPreferences _localPref = await SharedPreferences.getInstance();
    String userProfile = _localPref.getString(_kUserPref);
    if (userProfile != null) {
      Auth().setCurrentUser(User.fromMap(json.decode(userProfile)));
      setState(() {
        _routingWidget = ChatList();
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
        appBar: AppBar(
          title: Text('1Chat β'),
        ),
        body: _routingWidget,
      ),
      theme: ThemeData.dark(),
    );
  }
}
