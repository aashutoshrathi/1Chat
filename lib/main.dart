import 'package:flutter/material.dart';
import 'package:gdg_gnr/screens/login.dart';

void main() => runApp(MainWidget());

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('1Chat β'),
        ),
        body: LoginPage(),
        // bottomNavigationBar: BottomBar(),
        // drawer: CustomDrawer(),
      ),
      theme: ThemeData.dark(),
    );
  }
}
