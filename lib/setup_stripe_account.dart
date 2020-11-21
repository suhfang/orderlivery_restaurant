

import 'dart:convert';

import 'package:Restaurant/onboarding_page.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;

class SetupStripeAccountPage extends StatefulWidget {
  final String locationId;
  SetupStripeAccountPage({this.locationId});
  _SetupStripeAccountPageState createState() => _SetupStripeAccountPageState();
}

class _SetupStripeAccountPageState extends State<SetupStripeAccountPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Setup Stripe Account', style: TextStyle(fontWeight: FontWeight.bold),),
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:  Column(
            children: [
              Text('You will need to create a Stripe Account for this location in order to receive payments from Orderlivery. This is available at no cost to you and will allow your restaurant to track statistics, set up payment dates, and more!'),
              SizedBox(height: 40,),
              GestureDetector(
                onTap: openStripeOnBoardingLink,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Center(
                    child: Text('Take me Stripe and setup my account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  void openStripeOnBoardingLink() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.post('${Constants.apiBaseUrl}/restaurants/generate-onboarding-link', headers: {
      'token': token,
      'Content-Type': 'application/json'
    },
        body: json.encode({
          'location_id': widget.locationId
        }));
    print(response.body);
    final link = json.decode(response.body)['link'] as String;
   _launchInWebViewWithJavaScript(link);
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    // if (await canLaunch(url)) {
    //   await launch(
    //     url,
    //     forceSafariVC: true,
    //     forceWebView: true,
    //     enableJavaScript: true,
    //   );
    // } else {
    //   throw 'Could not launch $url';
    // }
    Navigator.push(context,
    MaterialPageRoute(
      builder: (context) => OnBoardingPage(initialUrl: url,)
    ));
  }
}