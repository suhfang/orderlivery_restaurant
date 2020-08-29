

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/primary_address.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;

class InitPage extends StatefulWidget {
  _InitPageState createState() => _InitPageState();
}


class _InitPageState extends State<InitPage> {

  @override
  void initState() {
    super.initState();
    doInit();
  }

  doInit() async {
    SharedPreferences prefs = await  SharedPreferences.getInstance();
    if (prefs.getString('token').isNotEmpty) {
      if (await hasPrimaryAddress()) {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PrimaryAddressPage()));
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: false)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<bool> hasPrimaryAddress() async {
    SharedPreferences prefs = await  SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.get('${Constants.apiBaseUrl}/restaurants/get-primary-address',
    headers: {
      'token': token,
      'Content-Type': 'application/json'
    });
    print(response.body);
    if (response.body.contains('null')) {
      return false;
    } else {
      return true;
    }
  }
}
