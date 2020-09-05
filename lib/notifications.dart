

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text('NOTIFICATIONS'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  ListTile(
                    title: Text('You have received an order from Suh Fangmbeng'),
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  ListTile(
                    title: Text('You have received an order from Suh Fangmbeng'),
                  ),
                  Divider(),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  ListTile(
                    title: Text('You have received an order from Suh Fangmbeng'),
                  ),
                  Divider(),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}