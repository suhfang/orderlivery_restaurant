

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/location_hub.dart';
import 'package:Restaurant/primary_address.dart';
import 'package:Restaurant/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;

class InitPage extends StatefulWidget {
  _InitPageState createState() => _InitPageState();
}


class _InitPageState extends State<InitPage> {


  AppUpdateInfo _updateInfo;
   bool _flexibleUpdateAvailable = false;
   GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
   
  @override
  void initState() {
    super.initState();
    doInit();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        print('found an update here it is: ${_updateInfo}');
      });
    }).catchError((e) => _showError(e));
  }

  void _showError(dynamic exception) {
    Fluttertoast.showToast(msg: exception.toString(), backgroundColor: Colors.red, textColor: Colors.white);
  }


  doInit() async {

    await checkForUpdate();

    if(_updateInfo?.updateAvailable == true) {
      await InAppUpdate.performImmediateUpdate().catchError((e) => _showError(e));
    }


    SharedPreferences prefs = await SharedPreferences.getInstance();

    if ((prefs.getString('token') ?? '').isNotEmpty) {

      bool is_restaurant = prefs.getBool('is_restaurant');
      bool is_location = prefs.getBool('is_location');
      print(is_restaurant);
        if (is_restaurant) {
          if (await filledProfile()) {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => HomePage()));
          } else {
            Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) =>
                    RestaurantDetailPage(showsNavBar: false,)));
          }
        }

        if (is_location) {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => LocationHubPage()));
        }

    } else {
        Navigator.push(context, MaterialPageRoute(
            builder: (BuildContext context) => AuthPage(loginTab: false)));
      }
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<bool> filledProfile() async {
    SharedPreferences prefs = await  SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/check-profile',
    headers: {
      'token': token,
      'Content-Type': 'application/json'
    });
    print(response.body);
    return !response.body.contains('false');
  }
}
