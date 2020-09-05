

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LegalPage extends StatefulWidget {
  _LegalPageState createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('LEGAL'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}