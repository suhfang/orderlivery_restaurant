

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocationFoodMenuPage extends StatefulWidget {
  _LocationFoodMenuPageState createState() => _LocationFoodMenuPageState();
}

class _LocationFoodMenuPageState extends State<LocationFoodMenuPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('LOCATION MENU'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}