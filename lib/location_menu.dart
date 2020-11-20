

import 'dart:convert';

import 'package:Restaurant/location_food_menu.dart';
import 'package:Restaurant/location_profile.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/restaurant_location_profile.dart';
import 'package:Restaurant/setup_stripe_account.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;

class LocationMenuPage extends StatefulWidget {
  final String addressName;
   String addressId;
  LocationMenuPage({this.addressName, @required this.addressId});
  _LocationMenuPageState createState() => _LocationMenuPageState();
}


class _LocationMenuPageState extends State<LocationMenuPage> {

  @override
  void initState() {
    super.initState();
    getStripeAccountInfo();
  }
  bool payouts_enabled = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.addressName),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            ListTile(
              title: Text('Location Details'),
              trailing: Icon(LineIcons.angle_right),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LocationProfilePage(locationId: widget.addressId,)));
              }
            ),
            !payouts_enabled ? ListTile(
                title: Text('Setup Stripe Account to start receiving payments', style: TextStyle(fontWeight: FontWeight.bold),),
                trailing: Icon(LineIcons.angle_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SetupStripeAccountPage(locationId: widget.addressId,)));
                }
            ) :  SizedBox()
          ],
        ),
      ),
    );
  }

  getStripeAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/get-stripe-account-info-for-location', headers: {
      'token': token,
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'location_id': widget.addressId
    }));
    print(response.body);
    final _payouts_enabled = json.decode(response.body)['account']['payouts_enabled'] as bool;
    setState(() {
      payouts_enabled = _payouts_enabled;
    });
  }

}
