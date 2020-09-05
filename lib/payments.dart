

import 'package:Restaurant/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      backgroundColor: Colors.white,
        title: 'PAYMENTS');
  }
}