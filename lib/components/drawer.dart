import 'package:flutter/material.dart';
import 'package:gdg_gnr/screens/auth.dart';
import 'package:gdg_gnr/screens/login.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              onTap: () {
                Auth().signOut();
                Navigator.pop(context, MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }));
              })
        ],
      ),
    );
  }
}
