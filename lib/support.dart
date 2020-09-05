



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('SUPPORT'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}