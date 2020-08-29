

import 'dart:convert';

import 'package:Restaurant/add_location.dart';
import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/menu.dart';
import 'package:Restaurant/profile.dart';
import 'package:Restaurant/ratings.dart';
import 'package:Restaurant/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:http/http.dart' as http;
import 'package:Restaurant/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class Address {

  final String name;
  final String lat;
  final String lon;
  final String id;
  Address({this.name, this.lat, this.lon, this.id});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        name: json['name'] as String,
        lat: json['lat'] as String,
        lon: json['lon'] as String,
        id: json['_id'] as String
    );
  }
}

class _HomePageState extends State<HomePage> {

  List<Address> _locations = [];
  String _restaurantName = '';

  @override
  void initState() {
    super.initState();
    getLocations();
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
    Iterable data = _json['locations'];
    print(data);
    final addresses = data.map((e) => Address.fromJson(e)).toList();
    setState(() {
      _locations = addresses;
      _restaurantName = _json['name'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Text('MY HUB'),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(LineIcons.bell),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(20                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ),
                child: ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final item = _locations[index];
                      return Dismissible(
                        background: stackBehindDismiss(),
                        direction: DismissDirection.endToStart,
                        key: Key(item.id),
                        onDismissed: (DismissDirection direction) {
                          deleteAddress(context, _locations[index].id);
                          setState(() {
                            _locations.removeAt(index);
                          });
                        },
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(_restaurantName),
                              subtitle: Text(item.name),
                            ),
                            Divider()
                          ],
                        ),
                      );
                    }
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () async {
                      String added = await Navigator.push(context, MaterialPageRoute(
                          builder: (BuildContext context) =>
                              AddLocationPage()));
                      print(added);
                      if (added == 'added') {
                        setState(() {
                          getLocations();
                        });
                      }
                    },
                    child: Container(
                      height: 50,
                      color: Colors.white,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 50,
                      child: Container(
                        height: 50,
                        color: Colors.orange,
                        child: Center(
                          child: Text('ADD LOCATION', style: TextStyle(
                              color: Colors.white),),
                        ),
                      ),
                    ),
                  )
              )
            ],
          ),
        ),
      ),

    );
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        LineIcons.trash,
        color: Colors.white,
      ),
    );
  }

  void deleteAddress(BuildContext context, String id) async {
    var url = Constants.apiBaseUrl + '/restaurants/remove-location';
    print(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    Future.delayed(Duration(seconds: 0), () async {
      var response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            'token': prefs.getString('token')
          },
          body: json.encode(
              {
                'id': id
              }
          )
      );
      print(response.body);
      setState(() {
        getLocations();
      });
    });
  }
  }



