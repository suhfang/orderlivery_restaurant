

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/legal.dart';
import 'package:Restaurant/notification_settings.dart';
import 'package:Restaurant/payment_settings.dart';
import 'package:Restaurant/profile_settings.dart';
import 'package:Restaurant/support.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:line_icons/line_icons.dart';

class SettingsPage extends StatefulWidget {
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      backgroundColor: Colors.white,
        title: 'ACCOUNT SETTINGS',
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  FlatButton(
                    onPressed: () async {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ProfileSettings()));
                    },
                    child: Padding(
                      padding:
                      EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Profile', style: TextStyle(fontSize: 19)),
                          Icon(LineIcons.angle_right),
                        ],
                      ),
                    ),
                  ),
//                  FlatButton(
//                    onPressed: () {
//                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PaymentSettings()));
//                    },
//                    child: Padding(
//                      padding:
//                      EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: <Widget>[
//                          Text('Payments', style: TextStyle(fontSize: 19)),
//                          Icon(LineIcons.angle_right),
//                        ],
//                      ),
//                    ),
//                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SupportPage()));
                    },
                    child: Padding(
                      padding:
                      EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Support', style: TextStyle(fontSize: 19)),
                          Icon(LineIcons.angle_right),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => NotificationSettings()));
                    },
                    child: Padding(
                      padding:
                      EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Notifications', style: TextStyle(fontSize: 19)),
                          Icon(LineIcons.angle_right),
                        ],
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LegalPage()));
                    },
                    child: Padding(
                      padding:
                      EdgeInsets.only(left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Legal', style: TextStyle(fontSize: 19)),
                          Icon(LineIcons.angle_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}