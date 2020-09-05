

import 'dart:convert';

import 'package:Restaurant/add_location.dart';
import 'package:Restaurant/drawer.dart';
import 'package:Restaurant/location_menu.dart';
import 'package:Restaurant/location_profile.dart';
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
 String name;
  String lat;
  String lon;

  Address({this.name, this.lat, this.lon});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] as String,
      lat: json['lat'] as String,
      lon: json['lon'] as String,
    );
  }
}

class RestaurantLocation {

  bool is_operating;
  Address address;

  final String id;
  RestaurantLocation({this.is_operating, this.address, this.id});

  factory RestaurantLocation.fromJson(Map<String, dynamic> json) {

    return RestaurantLocation(
        address: Address.fromJson(json['address']),
        id: json['_id'] as String,

    );
  }
}

class _HomePageState extends State<HomePage> {

  List<RestaurantLocation> _locations = [];
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

    final addresses = data.map((e) => RestaurantLocation.fromJson(e)).toList();

    setState(() {
      _locations = addresses;
      _restaurantName = _json['name'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DrawerScaffold(
      backgroundColor: Colors.white,
      title: 'MY HUB',
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              _locations.isNotEmpty ?
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

                            _locations.removeAt(index);
                        },
                        confirmDismiss: (DismissDirection direction) {
                            return deleteAddress(context, _locations[index], index);
                          },
                        child: GestureDetector(
                          onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LocationMenuPage(addressName: item.address.name, addressId: item.id,)));

                          },
                          child:  Column(
                            children: [
                              ListTile(
                                title: Text(_restaurantName + ' at'),
                                subtitle: Text(item.address.name),
                              ),
                              Divider()
                            ],
                          ),
                        )
                      );
                    }
                ),
              ) : Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text('Add multiple locations of your restaurant and manage them right here', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
        ),
      ),

              Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    children: [

                      GestureDetector(
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
                            height: 70,
                            child: Column(
                              children: [

                                SizedBox(height: 10,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  height: 50,

                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width - 50,
                                  child: Center(
                                    child: Text('ADD LOCATION', style: TextStyle(

//                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),),
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),

                    ],
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

  Future<bool> deleteAddress(BuildContext context, RestaurantLocation location, int index) async {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return Container(
        color: Color(0xFF737373),
        height: 200,
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(topRight: const Radius.circular(10), topLeft: const Radius.circular(10))
          ),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Container(
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 15,),
              Text('CONFIRM!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              SizedBox(height: 5,),
              Divider(),
              Padding(
                padding: EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
                child: Text('Are you sure you want to delete this location?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                  decoration: BoxDecoration(
                  ),
                  width: MediaQuery.of(context).size.width - 40,
                  height: 40,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: GestureDetector(
                            onTap: () async  {
//                              if (_locations.length > 1) {
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
                                            'id': location.id
                                          }
                                      )
                                  );
                                  Navigator.of(context).pop(true);
                                  setState(() {


                                    getLocations();
                                  });
                                });
                                return true;
//                              }
                            },
                            child:  Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              height: 50,
                              child: Center(child: Text('YES', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),),),

                            ),
                          )
                      ),
                      SizedBox(width: 10,),
                      Expanded(

                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);

                              setState(() {

                              });
                              return false;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.orange,
                              ),
                              height: 50,
                              child: Center(child: Text('NO', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),),

                            ),
                          )
                      ),
                    ],
                  )
              ),

            ],
          ),
        ),
      );
    });
  }
  }



