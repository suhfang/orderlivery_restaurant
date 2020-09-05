

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationSettings extends StatefulWidget {
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('NOTIFICATIONS'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}