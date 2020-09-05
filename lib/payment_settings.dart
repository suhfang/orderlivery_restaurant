





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentSettings extends StatefulWidget {
  _PaymentSettingsState createState() => _PaymentSettingsState();
}

class _PaymentSettingsState extends State<PaymentSettings> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('PAYMENTS'),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
    );
  }
}