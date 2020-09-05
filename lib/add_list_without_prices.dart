
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddListWithoutPricesPage extends StatefulWidget {

  _AddListWithoutPricesPageState createState() => _AddListWithoutPricesPageState();
}

class _AddListWithoutPricesPageState extends State<AddListWithoutPricesPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add List without Prices'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}