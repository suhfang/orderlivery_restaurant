

import 'package:Restaurant/categories.dart';
import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/upload.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class MenuPage extends StatefulWidget {
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('MENU'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(LineIcons.bell),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text('UPLOAD'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UploadPage()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('CATEGORY LIST'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CategoriesPage()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('MENU ITEMS'),
            ),
          ],
        ),
      ),
    );
  }
}