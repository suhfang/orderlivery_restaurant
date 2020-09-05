

import 'package:Restaurant/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationHubPage extends StatefulWidget {
  _LocationHubPageState createState() => _LocationHubPageState();
}

class _LocationHubPageState extends State<LocationHubPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ORDERS'),
        centerTitle: true,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Container(
            child: Stack(
              children: [
                ListView(
                  children: [
                    ListTile(
                      title: Text('ORDERS'),
                      leading: Icon(LineIcons.newspaper_o),
                    ),
                    ListTile(
                        tileColor: Colors.orange,
                        title: Text('LOG OUT',style: TextStyle(color: Colors.white),),
                        leading: Icon(LineIcons.sign_out, color: Colors.white,),
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', '');
                          await prefs.setBool('is_location', null);
                          await prefs.setBool('is_restaurant', null);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                        }
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}