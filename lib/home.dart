

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override

  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('MY HUB'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Icon(LineIcons.bell),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          child: ListView(
            children: [
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              ),
              Divider(),
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              ),
              Divider(),
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              ),
              Divider(),
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              ),
              Divider(),
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              ),
              Divider(),
              ListTile(
                title: Text('BFF Asian Grill and Bar'),
                subtitle: Text('2150 E Lamar Blvd Suite 100, Arlington, TX 76006'),
              )
            ],
          ),
        ),
      ),

    );
  }
}