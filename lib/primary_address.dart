

import 'package:Restaurant/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryAddressPage extends StatefulWidget {
  _PrimaryAddressPageState createState() => _PrimaryAddressPageState();
}

class _PrimaryAddressPageState extends State<PrimaryAddressPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Primary Address'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            child: Stack(
              children: [
                SizedBox(height: 50,),
                Text('What is the main location of your restaurant?', style: TextStyle(fontSize: 19),),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: CustomSearchScaffold(),
                )
              ],
            ),
          ),
        )
      )
    );
  }
}