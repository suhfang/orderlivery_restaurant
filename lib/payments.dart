

import 'dart:convert';

import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/stripe_dashboard.dart';
import 'package:commons/commons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;

class PaymentsPage extends StatefulWidget {
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {

  List<RestaurantLocation> _locations = [];
  RestaurantLocation selectedLocation;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocations();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          title: Column(
            children: [
              Text('Payments', style: TextStyle(fontWeight: FontWeight.bold),),

            ],
          ),
          backgroundColor: Colors.white,
        ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
             Row(
               children: [
                 Expanded(

                   child:  Container(
                     height: 50,
                     child: ButtonTheme(
                     alignedDropdown: true,
                     child: DropdownButton<RestaurantLocation>(
                      
                     isExpanded: true,
                     items: _locations.map((RestaurantLocation value) {
                       return new DropdownMenuItem<RestaurantLocation>(
                         value: value,
                         child:Text(value.address.name),

                       );
                     }).toList(),
                     onChanged: (location) {
                       setState(() {
                         selectedLocation = location;
                       });
                     },
                     hint: Text('Select a location to view its payments'),
                     value: selectedLocation != null ? selectedLocation :  null,
                   ) ,
                   )
                   )

                 )
               ]
             ),
              SizedBox(
                height: 20,
              ),
             selectedLocation  != null ?
             GestureDetector(
               onTap: ( ) {
                 viewStripeDashboardForLocation(location_id: selectedLocation.id);
               },
               child: Container(
                   padding: EdgeInsets.all(20),
                   height: 140,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(30),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.grey.withOpacity(0.5),
                         spreadRadius: 2,
                         blurRadius: 7,
                         offset: Offset(0, 3), // changes position of shadow
                       ),
                     ],
                   ),
                   child: Row(
                     children: [
                       Expanded(
                         child:GestureDetector(
                           onTap: () {
                              viewStripeDashboardForLocation(location_id: selectedLocation.id);
                           },
                           child:  Column(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               Icon(LineIcons.cc_stripe, size: 50,color: Colors.blue,),
                               Text('VIEW STRIPE DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold),)
                             ],
                           ),
                         ),
                       )
                     ],
                   )
               ),
             ) : SizedBox()
            ],
          ),
        )
      ),
    );
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

  getLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token');
    final response = await http.get(
        '${Constants.apiBaseUrl}/restaurants/get-locations', headers: {
      'token': token,
      'Content-Type': 'application/json',
    });
    var _json = json.decode(response.body);
    print(_json);
    Iterable data = _json['locations'];

    final addresses = data.map((e) => RestaurantLocation.fromJson(e)).toList().where((element) => element.activated == true).toList();
    print(addresses.map((e) => e.activated).toList());
    setState(() {
      _locations = addresses;

      // _restaurantName = _json['name'] as String;
    });
  }
}