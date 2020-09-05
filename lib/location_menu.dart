

import 'package:Restaurant/location_profile.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/restaurant_location_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';

class LocationMenuPage extends StatefulWidget {
  final String addressName;
   String addressId;
  LocationMenuPage({this.addressName, @required this.addressId});
  _LocationMenuPageState createState() => _LocationMenuPageState();
}


class _LocationMenuPageState extends State<LocationMenuPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.addressName),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            ListTile(
              title: Text('LOCATION DETAILS'),
              trailing: Icon(LineIcons.angle_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LocationProfilePage(locationId: widget.addressId,)));
              }
            ),
            ListTile(
              title: Text('MENU'),
              trailing: Icon(LineIcons.angle_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FoodMenuPage()));
                }
            ),
            ListTile(
              title: Text('ORDERS'),
              trailing: Icon(LineIcons.angle_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RestaurantLocationProfilePage()));
                }
            ),
            ListTile(
              title: Text('RATINGS'),
              trailing: Icon(LineIcons.angle_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => RestaurantLocationProfilePage()));
                }
            ),
          ],
        ),
      ),
    );
  }
}