

import 'package:Restaurant/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
        backgroundColor: Colors.white,
        title: 'ORDERS'
    );
  }
}