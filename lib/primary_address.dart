

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrimaryAddressPage extends StatefulWidget {
  _PrimaryAddressPageState createState() => _PrimaryAddressPageState();
}

class _PrimaryAddressPageState extends State<PrimaryAddressPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      endDrawer: Container(
        width: 200,
        child: Drawer(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('token', '');
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                },
                child: ListTile(tileColor: Colors.black, title: Text('LOG OUT', style: TextStyle(color: Colors.white),),),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('How can we find your restaurant?'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: CustomSearchScaffold(),
      )
    );
  }
}