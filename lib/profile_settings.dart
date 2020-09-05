





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSettings extends StatefulWidget {
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('PROFILE'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}