

import 'dart:convert';

import 'package:Restaurant/location_food_menu.dart';
import 'package:Restaurant/location_profile.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/restaurant_location_profile.dart';
import 'package:Restaurant/setup_stripe_account.dart';
import 'package:Restaurant/stripe_dashboard.dart';
import 'package:badges/badges.dart';
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
    bool activated;
  LocationMenuPage({this.activated, this.addressName, @required this.addressId});
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
        title: Text('${widget.addressName.split(', ')[0]}, ${widget.addressName.split(', ')[1]}, ${widget.addressName.split(', ')[2]}', overflow: TextOverflow.clip, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),

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
            !widget.activated ? ListTile(
                title: Badge(
                  child: Text('Setup a Stripe Account for this location to start receiving payments'),
                ),
                trailing: Icon(LineIcons.angle_right),
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SetupStripeAccountPage(locationId: widget.addressId,)));
                  getStripeAccountInfo();
                }
            ) :  ListTile(
                title: Text('View Stripe Dashboard'),
                trailing: Icon(LineIcons.angle_right),
                onTap: () async {
                  viewStripeDashboardForLocation(location_id: widget.addressId);
                }
            )
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
      widget.activated = _payouts_enabled;
    });
  }

  void viewStripeDashboardForLocation({String location_id}) async {
    String token = (await SharedPreferences.getInstance()).getString('token');
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/generate-login-url',
    headers: {
      'Content-Type': 'application/json',
      'token': token
    },
    body: json.encode({
      'location_id': location_id
    }));
    var url = json.decode(response.body)['link']['url'] as String;
    Navigator.push(context, MaterialPageRoute(builder: (context) => StripeDashboardPage(initialUrl: url,)));

  }

}
