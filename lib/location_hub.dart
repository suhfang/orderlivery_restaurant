

import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/auth.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:badges/badges.dart';
import 'package:commons/commons.dart';
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
  List<Order> new_orders = [];
  List<Order> past_orders = [];
  List<Order> current_orders = [];
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

  bool _allowing = false;
  String location_id;

  getLocationId() async  {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    print('soup');
    final response = await http.get('${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
   _firebaseMessaging.getToken().then((value) async {
     location_id = json.decode(response.body)['location_id'] as String;
     _firebaseMessaging.configure(
       onMessage: (Map<String, dynamic> message) async {
         print(message);
         print('app onMessage');
         getOrders(location_id: location_id);
       },
       onResume: (Map<String, dynamic> message) async {
         print(message);
         getOrders(location_id: location_id);
         print('app onResume');
       },
       onLaunch: (Map<String, dynamic> message) async {
         print(message);
         getOrders(location_id: location_id);
         print('app onLaunch');
       },
     );

     getAcceptanceStatus(location_id: location_id);
     getOrders(location_id: location_id);
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
                  onChanged: (bool newValue) async {
                    if (location_id != null) {
                      bool result = await setAcceptingStatus(value: newValue, location_id: location_id);
                      setState(()  {
                        _allowing = result;
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
                  new_orders.isNotEmpty ? Container(
                      height: 400,
                      child: new_orders.isNotEmpty ?
                          ListView.separated(itemBuilder: (context, index) {
                            final item = new_orders[index];
                            return Column(
                              children: [
                               Container(
                                 height: 200,
                                 child:  Column(
                                   children: [
                                     Container(
                                       height: 100,
                                       child: ListView.separated(

                                           itemBuilder: (context, subIndex) {
                                             final item = new_orders[index].items[subIndex];
                                             return Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 Row(
                                                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                   children: [
                                                     Text('(${item.quantity})'),
                                                     Text(item.name),
                                                     Text('\$${item.quantity*item.flat_price}'),
                                                 ],
                                                 ),
                                                 item.special_instructions != null && item.special_instructions.isNotEmpty ? Column(
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: [
                                                     SizedBox(height: 10,),
                                                     Text('Special instructions', style: TextStyle(fontWeight: FontWeight.bold),),
                                                     Text(item.special_instructions)
                                                   ],
                                                 ) : SizedBox()
                                               ],
                                             );
                                           }, separatorBuilder: (context, subIndex) {
                                         return Divider();
                                       }, itemCount: new_orders[index].items.length),
                                     ),

                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('ORDER TOTAL', style: TextStyle(fontWeight: FontWeight.bold),),
                                         Text('\$${item.food_total}', style: TextStyle(fontWeight: FontWeight.bold),),
                                       ],
                                     ),
                                     SizedBox(height: 10),
                                     Row(
                                       children: [
                                         Expanded(
                                           child: GestureDetector(
                                             onTap: () async {
                                               await acceptOrder(order_id: item.id);
                                             },
                                             child: Container(
                                               color: Colors.orange,
                                               height: 50,
                                               child: Center(
                                                 child: Text('ACCEPT'),
                                               ),
                                             ),
                                           )
                                         ),
                                         SizedBox(width: 10,),
                                         Expanded(
                                           child: GestureDetector(
                                             onTap: () async {
                                               await declineOrder(order_id: item.id);
                                             },
                                             child:  Container(
                                               color: Colors.red,
                                               height: 50,
                                               child: Center(
                                                 child: Text('REJECT'),
                                               ),
                                             ),
                                           )
                                         ),
                                       ],
                                     )
                                   ],
                                 )
                               )
                              ],
                            );
                          }, separatorBuilder: (context, index) {
                            return Divider();
                          }, itemCount: new_orders.length)
                          : SizedBox()
                  ) :  SizedBox(),
                  current_orders.isNotEmpty ? Container(
                      height: 400,
                      child: current_orders.isNotEmpty ?
                      ListView.separated(itemBuilder: (context, index) {
                        final item = current_orders[index];
                        return Column(
                          children: [
                            Container(
                                height: 200,
                                child:  Column(
                                  children: [
                                    Container(
                                      height: 100,
                                      child: ListView.separated(

                                          itemBuilder: (context, subIndex) {
                                            final item = current_orders[index].items[subIndex];
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Text('(${item.quantity})'),
                                                Text(item.name),
                                                Text('\$${item.quantity*item.flat_price}'),
                                              ],
                                            );
                                          }, separatorBuilder: (context, subIndex) {
                                        return Divider();
                                      }, itemCount: current_orders[index].items.length),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ORDER TOTAL', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('\$${item.food_total}', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                await finishOrder(order_id: item.id);
                                              },
                                              child: Container(
                                                color: Colors.orange,
                                                height: 50,
                                                child: Center(
                                                  child: Text('READY FOR PICKUP'),
                                                ),
                                              ),
                                            )
                                        ),

                                      ],
                                    )
                                  ],
                                )
                            )
                          ],
                        );
                      }, separatorBuilder: (context, index) {
                        return Divider();
                      }, itemCount: current_orders.length)
                          : SizedBox()
                  ) :  SizedBox(),
                  past_orders.isNotEmpty ? Container(
                      height: 350,
                      child: past_orders.isNotEmpty ?
                      ListView.separated(itemBuilder: (context, index) {
                        final item = past_orders[index];
                        return Column(
                          children: [
                            Container(
                                height: 150,
                                child:  Column(
                                  children: [
                                    Container(
                                      height: 100,
                                      child: ListView.separated(

                                          itemBuilder: (context, subIndex) {
                                            final item = past_orders[index].items[subIndex];
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Text('(${item.quantity})'),
                                                Text(item.name),
                                                Text('\$${item.quantity*item.flat_price}'),
                                              ],
                                            );
                                          }, separatorBuilder: (context, subIndex) {
                                        return Divider();
                                      }, itemCount: past_orders[index].items.length),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ORDER TOTAL', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('\$${item.food_total}', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                  ],
                                )
                            )
                          ],
                        );
                      }, separatorBuilder: (context, index) {
                        return Divider();
                      }, itemCount: past_orders.length)
                          : SizedBox()
                  ) :  SizedBox(),
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

  getOrders({String location_id}) async {
    audioPlugin.play('assets/sounds/sound.mp3', isLocal: true);
    print(location_id);
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/get-orders', headers: {
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'location_id': location_id
    }));
    Iterable _orders = json.decode(response.body);
    setState(() {
    print(_orders.length);
      var all = _orders.map((e) => Order.fromJson(e)).toList();
      print(all);
      new_orders = all.where((e) => e.approved_at == null && e.declined_at == null).toList();
      current_orders = all.where((e) => e.approved_at != null && e.picked_up_at == null).toList();
    past_orders = all.where((e) => e.picked_up_at != null || e.delivered_at != null || e.declined_at != null).toList();
      // print(new_orders);

    });
  }
  acceptOrder({String order_id}) async {
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/accept-order',
        headers: {
          'Content-Type': 'application/json',

        },
    body: json.encode({
      'order_id': order_id,
      'location_id': location_id
    }));
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('You accepted this order'),
    ));
    if (location_id != null) {
      getOrders(location_id: location_id);
    }
  }

  finishOrder({String order_id}) async {
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/finish-order',
        headers: {
          'Content-Type': 'application/json',

        },
        body: json.encode({
          'order_id': order_id,
          'location_id': location_id
        }));
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('You marked this order as ready for pickup'),
    ));
    if (location_id != null) {
      getOrders(location_id: location_id);
    }
  }
  declineOrder({String order_id}) async {
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/decline-order',
        headers: {
          'Content-Type': 'application/json',

        },
        body: json.encode({
          'order_id': order_id,
          'location_id': location_id
        }));
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('You declined this order'),
    ));
    if (location_id != null) {
      getOrders(location_id: location_id);
    }
  }
  setAcceptingStatus({bool value, String location_id}) async {

    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/set-status', headers: {
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'location_id': location_id,
      'allowing_orders': value
    }));
    print(response.body);
    bool result = json.decode(response.body)['result'] as bool;
    print(result);
    return result;
  }

static AudioPlayer audioPlugin = AudioPlayer();



  getAcceptanceStatus({String location_id}) async {
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/get-status', headers: {
      'Content-Type': 'application/json'
    },
        body: json.encode({
          'location_id': location_id,
        }));
    print(response.body);
    bool result = json.decode(response.body)['result'] as bool;
    print('initial');
    print(result);
   setState(() {
     _allowing = result;
   });
  }
}


class OrderItem {
  String name;
  int quantity;
  double flat_price;
  String special_instructions;
  OrderItem({this.name, this.quantity, this.flat_price, this.special_instructions});
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        flat_price: json['flat_price'] as double,
        special_instructions: json['special_instructions'] as String
    );
  }
}
class Order {
  String id;
  String restaurant_name;
  String restaurant_location_id;
  DateTime picked_up_at;
  String picked_up_by;
  String ordered_by;
  UserAddress delivery_address;
  String order_type;
  String status;
  DateTime approved_at;
  DateTime declined_at;
  DateTime delivered_at;
  DateTime cooked_at;
  List<OrderItem> items;
  double tax;
  double grand_total;
  double tip;
  double food_total;
  double service_fee;
  double discount_amount;
  PaymentMethod paymentMethod;

  Order({
    this.restaurant_name,
    this.restaurant_location_id,
    this.picked_up_at,
    this.picked_up_by,
    this.ordered_by,
    this.delivery_address,
    this.order_type,
    this.status,
    this.approved_at,
    this.declined_at,
    this.delivered_at,
    this.items,
    this.tax,
    this.grand_total,
    this.tip,
    this.food_total,
    this.service_fee,
    this.discount_amount,
    this.paymentMethod,
    this.id,
    this.cooked_at
  });


  factory Order.fromJson(Map<String, dynamic> json) {
    double convertToDouble(dynamic value) {
      if (value is int) {
        return value.toDouble();
      } else {
        return value;
      }
    }
    DateTime getDartDateFromNetUTC(String netUtcDate) {
      var dateParts = netUtcDate.split(".");
      var actualDate = DateTime.parse(dateParts[0] + "Z");
      return actualDate;
    }
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    Iterable _items = json['items'];
    return Order(
      restaurant_name: json['restaurant_name'] as String,
      restaurant_location_id: json['restaurant_location_id'] as String,
      picked_up_at: json['picked_up_at'] != null ? getDartDateFromNetUTC(
          json['picked_up_at'] as String) : null,
      picked_up_by: json['picked_up_by'] as String,
      ordered_by: json['ordered_by'] as String,
      delivery_address: json['delivery_address'] != null ? UserAddress
          .fromJson(json['delivery_address']) : null,
      order_type: json['order_type'] as String,
      status: json['status'] as String,
      approved_at: json['approved_at'] != null ? getDartDateFromNetUTC(
          json['approved_at'] as String) : null,
      declined_at: json['declined_at'] != null ? getDartDateFromNetUTC(
          json['declined_at'] as String) : null,
      delivered_at: json['delivered_at'] != null ? getDartDateFromNetUTC(
          json['delivered_at'] as String) : null,
        cooked_at: json['cooked_at'] != null ? getDartDateFromNetUTC(
            json['cooked_at'] as String) : null,
      items: _items.map((e) => OrderItem.fromJson(e)).toList(),
      tax: convertToDouble(json['tax']),
      grand_total: convertToDouble(json['grand_total']),
      tip: convertToDouble(json['tip']),
      food_total: convertToDouble(json['food_total']),
      service_fee: convertToDouble(json['service_fee']),
      discount_amount: json['discount_amount'],
      id: json['_id'] as String
      // paymentMethod: PaymentMethod.fromJson(json['payment_method'])

    );



  }

}

class UserAddress {
  String name;
  String id;
  String lat;
  String lon;
  UserAddress({this.id, this.name, this.lat, this.lon});
  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
        name: json['name'] as String,
        lat: json['lat'] as String,
        lon: json['lon'] as String
    );
  }
}


class BillingAddress {
  final String city;
  final String country;
  final String line1;
  final String line2;
  final String postal_code;
  final String state;

  BillingAddress(this.city, this.country, this.line1, this.line2,
      this.postal_code, this.state);

  Map<String, dynamic> toJson() {
    return {
      'city': this.city ?? null,
      'country': this.country ?? null,
      'line1': this.line1 ?? null,
      'line2': this.line2 ?? null,
      'postal_code': this.postal_code ?? null
    };
  }
}

class BillingDetails {
  final BillingAddress address;
  final String email;
  final String name;
  final String phone;

  BillingDetails(this.address, this.email, this.name, this.phone);

  Map<String, dynamic> toJson() {
    return {
      'email': this.email ?? null,
      'name': this.name ?? null,
      'phone': this.phone ?? null,
      'address': this.address.toJson() ?? null,
    };
  }
}

class Card {
  final String brand;
  final String country;
  final int exp_month;
  final int exp_year;
  final String last4;

  Card(this.brand, this.country, this.exp_month, this.exp_year, this.last4);
  Map<String, dynamic> toJson() {
    return {
      'brand': this.brand ?? null,
      'country': this.country ?? null,
      'exp_month': this.exp_month ?? null,
      'exp_year': this.exp_year ?? null,
      'last4': this.last4 ?? null
    };
  }
}

class PaymentMethod {
  final String optionalName;
  final String id;
  final String object;
  final Card card;
  final BillingDetails billingDetails;
  final String customer;
  bool isDefault = false;

  PaymentMethod(
      {this.id,
        this.object,
        this.billingDetails,
        this.card,
        this.customer,
        this.optionalName});

  Map<String, dynamic> toJson() {
    if (this.card != null) {
      return {
        'id': this.id,
        'optional_name': this.optionalName != null ? this.optionalName : null,
        'object': this.object ?? null,
        'card': this.card.toJson() ?? null,
        'billing_details': this.billingDetails.toJson() ?? null,
        'customer': this.customer ?? null,
      };
    } else {
      return {
        'id': this.id
      };
    }
  }
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    var billing_details_map = json['billing_details'] as Map<String, dynamic>;
    var billing_address_map =
    billing_details_map['address'] as Map<String, dynamic>;
    var card_map = json['card'] as Map<String, dynamic>;
    var customer = json['customer'] as String;

    BillingAddress billingAddress = BillingAddress(
        billing_address_map['city'] as String,
        billing_address_map['country'] as String,
        billing_address_map['line1'] as String,
        billing_address_map['line2'] as String,
        billing_address_map['postal_code'] as String,
        billing_address_map['state'] as String);

    BillingDetails billingDetails = BillingDetails(
        billingAddress,
        billing_details_map['email'] as String,
        billing_details_map['name'] as String,
        billing_details_map['phone'] as String);

    Card card = Card(
        card_map['brand'] as String,
        card_map['country'] as String,
        card_map['exp_month'] as int,
        card_map['exp_year'] as int,
        card_map['last4'] as String);
    return PaymentMethod(
      id: json['id'] as String,
      object: json['object'] as String,
      billingDetails: billingDetails,
      card: card,
      customer: customer,
    );
  }



}
