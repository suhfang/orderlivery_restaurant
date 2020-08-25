

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class UsersPage extends StatefulWidget {
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('USERS'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(LineIcons.bell),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}