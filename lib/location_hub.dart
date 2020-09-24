

import 'dart:convert';

import 'package:Restaurant/auth.dart';
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

  List<CartItem> items_to_buy = [];
  String order_id;
  double order_total;

  @override
  void initState() {
    super.initState();
    print(widget.notificationData);
    Constants.isOnOrdersPage = true;
   if (widget.notificationData != null) {
     Iterable items = json.decode(widget.notificationData['gcm.notification.additional_data'])['items'];
     order_id = json.decode(widget.notificationData['gcm.notification.additional_data'])['order_id'] as String;
     order_total = json.decode(widget.notificationData['gcm.notification.additional_data'])['amount'];
     items_to_buy = items.map((e) => CartItem.fromJson(e)).toList();
     print(items_to_buy);

   }
  }

  bool _allowing = true;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
      DefaultTabController(
        length: 3,
      child:  Scaffold(
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
                  },
                ),
              ],
            ),
            SizedBox(height: 20,),
            TabBar(
              tabs: [
                Tab(
                  child:  Text('New orders', textAlign: TextAlign.center,),
                ),
                Tab(
                  child:  Text('In-progress orders', textAlign: TextAlign.center,),
                ),
                Tab(
                  child:  Text('Past orders', textAlign: TextAlign.center,),
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
}