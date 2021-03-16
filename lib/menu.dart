

import 'package:Restaurant/categories.dart';
import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/menu_items.dart';
import 'package:Restaurant/upload.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class FoodMenuPage extends StatefulWidget {
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends State<FoodMenuPage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      backgroundColor: Colors.white,
      title: 'Menu',
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text('Upload', style: TextStyle(fontWeight: FontWeight.bold),),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => UploadPage()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CategoriesPage()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('Menu Items', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MenuItemsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}