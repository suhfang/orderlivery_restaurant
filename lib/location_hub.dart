

import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/auth.dart';
import 'package:badges/badges.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:http/http.dart' as http;

class LocationHubPage extends StatefulWidget {

  Map<String, dynamic> notificationData;
   LocationHubPage({this.notificationData});
  _LocationHubPageState createState() => _LocationHubPageState();
}

class CartItem {
  String name;
  String price;
  double quantity;
  String pricing_type;
  CartItem({this.name, this.price, this.quantity, this.pricing_type});
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'] as String,
      price: json['price'] as String,
      quantity: json['quantity'].toDouble()
    );
  }
}
class _LocationHubPageState extends State<LocationHubPage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<CartItem> items_to_buy = [];
  String order_id;
  double order_total;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

   //  Constants.isOnOrdersPage = true;
   // if (widget.notificationData != null) {
   //   Iterable items = json.decode(widget.notificationData['gcm.notification.additional_data'])['items'];
   //   order_id = json.decode(widget.notificationData['gcm.notification.additional_data'])['order_id'] as String;
   //   order_total = json.decode(widget.notificationData['gcm.notification.additional_data'])['amount'];
   //   items_to_buy = items.map((e) => CartItem.fromJson(e)).toList();

     print('fuck');
     getLocationId();
    // setToken();
   // }
  }

  bool _allowing = true;
  String location_id;

  getLocationId() async  {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    print('soup');
    final response = await http.get('${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
   _firebaseMessaging.getToken().then((value) async {
     location_id = json.decode(response.body)['location_id'] as String;
      if (location_id != null) {
        final _response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/set-firebase-messaging-token', headers: {
          'Content-Type': 'application/json'
        },
            body: json.encode({
              'token': value,
              'location_id': location_id,
              'device_id': await _getId()
            }));
        print(_response.body);
      }
   });

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      DefaultTabController(
        length: 3,
      child:  Scaffold(
        key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('ORDERS'),
        centerTitle: true,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Container(
            child: Stack(
              children: [
                ListView(
                  children: [
                    ListTile(
                      title: Text('ORDERS'),
                      leading: Icon(LineIcons.newspaper_o),
                    ),
                    ListTile(
                        tileColor: Colors.orange,
                        title: Text('LOG OUT',style: TextStyle(color: Colors.white),),
                        leading: Icon(LineIcons.sign_out, color: Colors.white,),
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', '');
                          await prefs.setBool('is_location', null);
                          await prefs.setBool('is_restaurant', null);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                        }
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Allowing Orders',),
                CupertinoSwitch(
                  value: _allowing,
                  onChanged: (bool newValue) {
                    setState(() {
                      _allowing = newValue;
                    });
                    if (!_allowing) {
                      scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text('You are no longer accepting orders'),
                        )
                      );
                    } else {
                      scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text('You are now accepting orders'),
                          )
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
            TabBar(
              tabs: [
                Tab(
                  child:  Badge(
                    child: Text('New orders', textAlign: TextAlign.center,)
                  ),
                ),
                Tab(
                  child:  Badge(
                      child: Text('In-progress orders', textAlign: TextAlign.center,)
                  ),
                ),
                Tab(
                  child:  Badge(
                      child: Text('Past orders', textAlign: TextAlign.center,)
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            Container(
              height: MediaQuery.of(context).size.height-267,
              child: TabBarView(
                children: [
                  widget.notificationData != null ? Container(
                      height: 400,
                      child: Column(
                        children: [
                          Container(
                            height: 300,
                            child: ListView.builder(
                              itemCount: items_to_buy.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    title: Text(items_to_buy[index].name + '  (${(items_to_buy[index].quantity)})'),
                                    trailing: Text('\$${(double.parse(items_to_buy[index].price)*items_to_buy[index].quantity).toStringAsFixed(2)}')
                                );
                              },
                            ),
                          ),
                          ListTile(
                            title: Text('ORDER TOTAL', style: TextStyle(fontWeight: FontWeight.bold),),
                            trailing: Text('\$${order_total}', style: TextStyle(fontWeight: FontWeight.bold),),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      final response = await http.post('${Constants.apiBaseUrl}/restaurants/complete-order',
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'token': prefs.getString('token')
                                          },
                                          body: json.encode({
                                            'order_id': order_id,
                                          }));
                                      widget.notificationData = null;
                                      setState(() {

                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text('ACCEPT', style: TextStyle(color: Colors.white),),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                  )
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.notificationData = null;
                                      setState(() {

                                      });
//                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LocationHubPage()));
                                    },
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text('DECLINE', style: TextStyle(color: Colors.white),),
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                  )
                              )
                            ],
                          )
                        ],
                      )
                  ) :  SizedBox(),
                  Text('In Progress Orders'),
                  Text('Past Orders'),
                ],
              ),
            )
          ],
        )
      )
    )
      );
  }


  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}