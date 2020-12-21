

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
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:line_icons/line_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

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
class _LocationHubPageState extends State<LocationHubPage>   with WidgetsBindingObserver {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<CartItem> items_to_buy = [];
  List<Order> new_orders = [];
  List<Order> past_orders = [];
  List<Order> current_orders = [];
  String order_id;
  double order_total;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    handleWakeLock();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
    if (_notification.index == 0) getOrders(location_id: location_id);
  
  }

String printIpAddress = '192.168.14.243';
double port = 9100;
NetworkPrinter printer;

Future<bool> initializePrinter(String ip) async {
  const PaperSize  paper = PaperSize.mm80;
  final profile = await CapabilityProfile.load();
  printer = NetworkPrinter(paper, profile);
  var res = await connectPrinter(printIpAddress);
  return res;
} 

Future<bool> connectPrinter(String ip) async {
  final PosPrintResult res = await printer.connect(ip, port: 9100);
  bool val = res == PosPrintResult.success;
  print ('printer connected: $val');
  
  return res == PosPrintResult.success;
}

void printItem(OrderItem item, int count) async {
 
 
  printer.text('${item.quantity} x ${item.name}', linesAfter: 1, styles: PosStyles(codeTable: 'CP1252', align: PosAlign.center), containsChinese: true,);
  if (item.special_instructions != null && item.special_instructions.isNotEmpty) {
    printer.feed(1);
    printer.text('Special instructions: ', linesAfter: 1, styles: PosStyles(bold: true));
    printer.text('${item.special_instructions}', linesAfter: 1);
    printer.feed(1);
  }
  item.lists.forEach((element) {
    printer.text('${element.name}:', linesAfter: 1, styles: PosStyles(align: PosAlign.center));
    element.items.forEach((elem) {
      if (elem.quantity != 0) {
        printer.text('${elem.quantity} x ${elem.name}', linesAfter: 1, styles: PosStyles(align: PosAlign.center)); 
      } else {
        printer.text('${elem.name}', linesAfter: 1, styles: PosStyles(align: PosAlign.center)); 
      }
    });
    printer.feed(1);
  });
  printer.text('------------------------------------------', linesAfter: 1, styles: PosStyles(align: PosAlign.center));
}



// void testReceipt(NetworkPrinter printer) {
//   printer.text(
//         'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//   printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//       styles: PosStyles(codeTable: 'CP1252'));
//   printer.text('Special 2: blåbærgrød',
//       styles: PosStyles(codeTable: 'CP1252'));

//   printer.text('Bold text', styles: PosStyles(bold: true));
//   printer.text('Reverse text', styles: PosStyles(reverse: true));
//   printer.text('Underlined text',
//       styles: PosStyles(underline: true), linesAfter: 1);
//   printer.text('Align left', styles: PosStyles(align: PosAlign.left));
//   printer.text('Align center', styles: PosStyles(align: PosAlign.center));
//   printer.text('Align right',
//       styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//   printer.text('Text size 200%',
//       styles: PosStyles(
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ));

//   printer.feed(2);
//   printer.cut();
// }


  @override
  void initState() {
    super.initState();
    
    // initializePrinter(printIpAddress);
    
    WidgetsBinding.instance.addObserver(this);



  Wakelock.enable();
   //  Constants.isOnOrdersPage = true;
   // if (widget.notificationData != null) {
   //   Iterable items = json.decode(widget.notificationData['gcm.notification.additional_data'])['items'];
   //   order_id = json.decode(widget.notificationData['gcm.notification.additional_data'])['order_id'] as String;
   //   order_total = json.decode(widget.notificationData['gcm.notification.additional_data'])['amount'];
   //   items_to_buy = items.map((e) => CartItem.fromJson(e)).toList();
  

     getLocationId();
    // setToken();
   // }
  }

  bool _allowing = false;
  String location_id;


  handleWakeLock() async {
    if (await Wakelock.enabled) {
      Wakelock.disable();
    }
  }

  getLocationId() async  {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    print(prefs.getString('token'));
    print('soup');
    final response = await http.get('${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
   _firebaseMessaging.getToken().then((value) async {
     location_id = json.decode(response.body)['location_id'] as String;
     _firebaseMessaging.configure(
       onMessage: (Map<String, dynamic> message) async {
         await FlutterRingtonePlayer.playNotification();
         print(message);
         print('app onMessage');
         showNotification(title: message['title'], body: message['body']);
         getOrders(location_id: location_id);
       },
       onResume: (Map<String, dynamic> message) async {
         await FlutterRingtonePlayer.playNotification();
         showNotification(title: message['title'], body: message['body']);
         print(message);
         getOrders(location_id: location_id);
         print('app onResume');
       },
       onLaunch: (Map<String, dynamic> message) async {
         await FlutterRingtonePlayer.playNotification();
         showNotification(title: message['title'], body: message['body']);
         print(message);
         getOrders(location_id: location_id);
         print('app onLaunch');
       },
     );

     getAcceptanceStatus(location_id: location_id);
     getOrders(location_id: location_id);
      if (location_id != null) {
        String deviceId = await _getId();
        final _response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/set-firebase-messaging-token', headers: {
          'Content-Type': 'application/json'
        },
            body: json.encode({
              'token': value,
              'location_id': location_id,
              'device_id': deviceId
            }));
        print(_response.body);
      }
   });

  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:  DefaultTabController(
        length: 3,
      child:  Scaffold(
        key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
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
                      title: Text('Orders'),
                      leading: Icon(LineIcons.newspaper_o),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                        tileColor: Colors.orange,
                        title: Text('Log Out',style: TextStyle(color: Colors.white),),
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
        child: Container(
          height: MediaQuery.of(context).size.height-6,
          width: MediaQuery.of(context).size.width,
          child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Allowing Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Platform.isIOS ?
                  CupertinoSwitch(
                    activeColor: Colors.orange,
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
                  ) :
                  Switch(
                    activeColor: Colors.orange,
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
            ),
            SizedBox(height: 20,),
            TabBar(
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,

              indicator: BoxDecoration(),
              labelColor: Colors.orange,
              tabs: [
                Tab(

                  child:  new_orders.isNotEmpty ?
                  Badge(
                      child: Container(
                        width: 150,
                        child: Text('New', textAlign: TextAlign.center,),
                      )
                  ) :  Container(
                    width: 150,
                    child: Text('New', textAlign: TextAlign.center,),
                  )
                ),
                Tab(
                  child:  current_orders.isNotEmpty ?
                  Badge(
                      child: Container(
                        width: 150,
                        child: Text('In-progress', textAlign: TextAlign.center,),
                      )
                  ) : Container(
                    width: 150,
                    child: Text('In-progress', textAlign: TextAlign.center,),
                  )
                ),
                Tab(
                  child:  past_orders.isNotEmpty ?
                  Badge(
                      child: Container(
                        width: 150,
                        child: Text('Past', textAlign: TextAlign.center,),
                      )
                  ) : Container(
                    width: 150,
                    child: Text('Past', textAlign: TextAlign.center,),
                  )
                ),
              ],
            ),
            SizedBox(height: 20,),
            Expanded(
              child:   Container(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                children: [
                  new_orders.isNotEmpty ? Container(
                      height: 500,
                      child: new_orders.isNotEmpty ?
                          ListView.separated(
                              itemBuilder: (context, index) {
                            final item = new_orders[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${DateFormat.yMMMMEEEEd().format(new_orders[index].orderedAt)} at ${DateFormat('kk:mm a').format(new_orders[index].orderedAt)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                Text('Ordered by: ${new_orders[index].customer_name}\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                Container(
                                    height: 400,
                                    child:  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 300,
                                          child: ListView.separated(
                                           physics: NeverScrollableScrollPhysics(),
                                           itemBuilder: (context, subIndex) {
                                             final item = new_orders[index].items[subIndex];
                                             return Container(
                                                 width: MediaQuery.of(context).size.width,
                                                 child: SingleChildScrollView(
                                                   scrollDirection: Axis.horizontal,
                                                   child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('${item.quantity}'),
                                                              Text(' x ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                              Text(item.name + '          '),
                                                            ],
                                                          ),
                                                          item.quantity != null && item.flat_price != null ?
                                                          Text('\$${(item.quantity*item.flat_price).toStringAsFixed(2)}') : 
                                                          item.flat_price != null ?
                                                          Text('\$${(item.flat_price).toStringAsFixed(2)}')  : 
                                                          Text('${item.name}')
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      ...(item.lists.map((e) {
                                                        return Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(e.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                                            ...( e.items.map((e) {
                                                              if (e.quantity != null && e.quantity != 0) {
                                                                  if (e.price != null && e.price != 0) {
                                                                    return Text('${e.quantity} x ${e.name} = \$${e.price}');
                                                                  } else {
                                                                    return Text('${e.quantity} x ${e.name}');
                                                                  }
                                                              } else {
                                                                if (e.price != null && e.price != 0) {
                                                                    return Text('${e.name} = \$${e.price}');
                                                                  } else {
                                                                    return Text('${e.name}');
                                                                  }
                                                              }
                                                              }).toList()),
                                                              SizedBox(height: 50)
                                                            ],
                                                        );
                                                      }).toList())                               
                                                      ],
                                                   )
                                                )
                                             );
                                           }, separatorBuilder: (context, subIndex) {
                                         return Divider();
                                       }, itemCount: new_orders[index].items.length),
                                     ),
                                  
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Food Total', style: TextStyle(fontWeight: FontWeight.bold),),
                                         Text('\$${item.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold),),
                                       ],
                                     ),
                                     SizedBox(height: 10),
                                     Row(
                                       children: [
                                         Expanded(
                                           child: GestureDetector(
                                             onTap: () async {
                                               await acceptOrder(order: item);
                                             },
                                             child: Container(
                                               height: 40,
                                               child: Center(
                                                 child: Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                                               ),
                                               decoration: BoxDecoration(
                                                 color: Colors.orange,
                                                 borderRadius: BorderRadius.circular(30)
                                               ),
                                             ),
                                           )
                                         ),
                                         SizedBox(width: 10,),
                                         Expanded(
                                           child: GestureDetector(
                                             onTap: () {
                                               showModalBottomSheet(context: context, builder: (context) {
                                                 return Container(
                                                   height: 150,
                                                   color: Colors.white,
                                                   child: Padding(
                                                       padding: EdgeInsets.all(10),
                                                       child: Column(
                                                         children: [
                                                           Expanded(
                                                             child:  Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Text('Are you sure you want to reject this order?', style: TextStyle(fontSize: 17),)
                                                               ],
                                                             ),
                                                           ),
                                                           Expanded(
                                                             child:  Row(
                                                               children: [
                                                                 Expanded(
                                                                     child: GestureDetector(
                                                                       onTap: () {
                                                                         declineOrder(order_id: item.id);
                                                                         Navigator.pop(context);
                                                                         scaffoldKey.currentState.showSnackBar(
                                                                             SnackBar(
                                                                               content: Text('You rejected this order '),
                                                                             )
                                                                         );
                                                                       },
                                                                       child: Container(
                                                                         height: 50,
                                                                         child: Center(
                                                                           child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold),),
                                                                         ),
                                                                         decoration: BoxDecoration(
                                                                             color: Colors.orange,
                                                                             borderRadius: BorderRadius.circular(20)
                                                                         ),
                                                                       ),
                                                                     )
                                                                 ),
                                                                 Expanded(
                                                                     child: GestureDetector(
                                                                       onTap: () {
                                                                         Navigator.pop(context);


                                                                       },
                                                                       child: Container(
                                                                         height: 50,
                                                                         child: Center(
                                                                           child: Text('No', style: TextStyle(fontWeight: FontWeight.bold),),
                                                                         ),
                                                                         decoration: BoxDecoration(
                                                                             color: Color(0xF1F1F1F1),
                                                                             borderRadius: BorderRadius.circular(20)
                                                                         ),
                                                                       ),
                                                                     )
                                                                 )
                                                               ],
                                                             ),
                                                           )
                                                         ],
                                                       )
                                                   ),
                                                 );
                                               });
                                             },
                                             child:  Container(
                                               height: 40,
                                               child: Center(
                                                 child: Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                                               ),
                                               decoration: BoxDecoration(
                                                   color: Color(0xF1F1F1F1),
                                                   borderRadius: BorderRadius.circular(30)
                                               ),
                                             ),
                                           )
                                         ),
                                       ],
                                     ),
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
                      height: 500,
                      child: current_orders.isNotEmpty ?
                      ListView.separated(itemBuilder: (context, index) {
                        final item = current_orders[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat.yMMMMEEEEd().format(current_orders[index].orderedAt)} at ${DateFormat('kk:mm a').format(current_orders[index].orderedAt)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                            Text('Ordered by: ${current_orders[index].customer_name}\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),

                            SizedBox(height: 20,),
                            Container(
                                height: 400,
                                child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 300,
                                      child: ListView.separated(
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subIndex) {
                                            final item = current_orders[index].items[subIndex];//
                                            return Container(
                                                width: MediaQuery.of(context).size.width,
                                                child:SingleChildScrollView(
                                                   scrollDirection: Axis.horizontal,
                                                   child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(

                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('${item.quantity}'),
                                                              Text(' x ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                              Text(item.name + '          '),
                                                            ],
                                                          ),
                                                          item.quantity != null && item.flat_price != null ?
                                                          Text('\$${(item.quantity*item.flat_price).toStringAsFixed(2)}') : 
                                                          item.flat_price != null ?
                                                          Text('\$${(item.flat_price).toStringAsFixed(2)}')  : 
                                                          Text('${item.name}')

                                                           
                                                          
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                        ...(item.lists.map((e) {
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(e.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                                           ...( e.items.map((e) {
                                                             if (e.quantity != null && e.quantity != 0) {
                                                                if (e.price != null && e.price != 0) {
                                                                  return Text('${e.quantity} x ${e.name} = \$${e.price}');
                                                                } else {
                                                                  return Text('${e.quantity} x ${e.name}');
                                                                }
                                                             } else {
                                                               if (e.price != null && e.price != 0) {
                                                                  return Text('${e.name} = \$${e.price}');
                                                                } else {
                                                                  return Text('${e.name}');
                                                                }
                                                             }
                                                            }).toList()),
                                                            SizedBox(height: 50)
                                                          ],
                                                      );
                                                    }).toList())
                                                                                                                
                                                      ],
                                                   )
                                                )
                                           );
                                          }, separatorBuilder: (context, subIndex) {
                                        return Divider();
                                      }, itemCount: current_orders[index].items.length),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Food Total', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('\$${item.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: item.approved_at != null && item.cooked_at == null ?
                                            GestureDetector(
                                              onTap: () async {
                                                await finishOrder(order_id: item.id);
                                              },
                                              child: Container(
                                                height: 45,
                                                child: Center(
                                                  child: Text('Ready for Pickup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Color(0xF1F1F1F1),
                                                    borderRadius: BorderRadius.circular(30)
                                                ),
                                              ),
                                            ) :
                                           GestureDetector(
                                             onTap: () {
                                                showCupertinoModalPopup(context: context, builder: (context) {
                                                  return Scaffold(
                                                    backgroundColor: Colors.white,
                                                    body: SafeArea(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(20),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                           Row(
                                                             mainAxisAlignment: MainAxisAlignment.start,
                                                             children: [
                                                               GestureDetector(
                                                                 onTap: () {
                                                                   Navigator.pop(context);
                                                                 },
                                                                 child: Padding(
                                                                   padding: EdgeInsets.all(20),
                                                                   child: Icon(LineIcons.close),
                                                                 ),
                                                               ),
                                                             ],
                                                           ),
                                                            Container(
                                                              width: MediaQuery.of(context).size.width,
                                                              color: Colors.white,
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [

                                                                SizedBox(height: 50,),
                                                              Text('Scan the QR Code below to collect your assigned order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19), textAlign: TextAlign.center,),
                                                              SizedBox(height: 50,),
                                                             Container(
                                                               width: 300,
                                                               height: 300,
                                                               child:  Stack(
                                                                 children: [
                                                                   Container(
                                                                     child: QrImage(
                                                                       data: item.id,
                                                                       foregroundColor: Colors.white,
                                                                       version: QrVersions.auto,
                                                                       size: 300.0,
                                                                     ),
                                                                     decoration: BoxDecoration(
                                                                        color: Colors.orange,
                                                                       borderRadius: BorderRadius.circular(30),
                                                                     ),
                                                                   ),
                                                                   Align(
                                                                     alignment: Alignment.center,
                                                                     child: ClipRRect(
                                                                       child: Image.asset('assets/images/qr-logo.png', height: 50, width: 50,),
                                                                       borderRadius: BorderRadius.circular(10),
                                                                     )
                                                                   )
                                                                 ],
                                                               )
                                                             )
                                                                ],
                                                              )
                                                            ),
                                                          ],
                                                        )
                                                      )
                                                    )
                                                  );
                                                });
                                             },
                                             child:  Container(

                                               height: 45,
                                               child: Center(
                                                 child: Text('Hand to Driver', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                                               ),
                                               decoration: BoxDecoration(
                                                   color: Color(0xF1F1F1F1),
                                                   borderRadius: BorderRadius.circular(30)
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
                      height: 500,
                      child: past_orders.isNotEmpty ?
                      ListView.separated(
                          itemBuilder: (context, index) {
                        final item = past_orders[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat.yMMMMEEEEd().format(past_orders[index].orderedAt)} at ${DateFormat('kk:mm a').format(past_orders[index].orderedAt)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                            Text('Ordered by: ${past_orders[index].customer_name}\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                            Container(
                                height: 400,
                                child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 300,
                                      child: ListView.separated(
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, subIndex) {
                                            final item = past_orders[index].items[subIndex];
                                            return Container(
                                              width: MediaQuery.of(context).size.width,
                                              child:SingleChildScrollView(
                                                   scrollDirection: Axis.horizontal,
                                                   child: Column(
                                                     crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(

                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('${item.quantity}'),
                                                              Text(' x ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                                                              Text(item.name + '          '),
                                                            ],
                                                          ),
                                                          item.quantity != null && item.flat_price != null ?
                                                          Text('\$${(item.quantity*item.flat_price).toStringAsFixed(2)}') : 
                                                          item.flat_price != null ?
                                                          Text('\$${(item.flat_price).toStringAsFixed(2)}')  : 
                                                          Text('${item.name}')           
                                                          
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                 ...(item.lists.map((e) {
                                                      return Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(e.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                                           ...( e.items.map((e) {
                                                             if (e.quantity != null && e.quantity != 0) {
                                                                if (e.price != null && e.price != 0) {
                                                                  return Text('${e.quantity} x ${e.name} = \$${e.price}');
                                                                } else {
                                                                  return Text('${e.quantity} x ${e.name}');
                                                                }
                                                             } else {
                                                               if (e.price != null && e.price != 0) {
                                                                  return Text('${e.name} = \$${e.price}');
                                                                } else {
                                                                  return Text('${e.name}');
                                                                }
                                                             }
                                                            }).toList()),
                                                            SizedBox(height: 50)
                                                          ],
                                                      );
                                                    }).toList())
                                                                                                    
                                                      ],
                                                   )
                                                )
                                         );
                                          }, separatorBuilder: (context, subIndex) {
                                        return Divider();
                                      }, itemCount: past_orders[index].items.length),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Food Total', style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text('\$${item.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold),),
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
       
            )
         ],
        )
  
        )    )
    )
      )
 
    );
  }


  void showNotification({
    String title,
    String body,
  }) {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        'your channel description',
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'ticker',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('arrive')
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
     android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
    );
    flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics, payload: 'sounds/sound.mp3',);


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
    // all.sort((a,b) {
    //   return b.createdAt.compareTo(a.createdAt);
    // });
    //   print(all);
      new_orders = all.where((e) => e.approved_at == null && e.declined_at == null).toList();
      current_orders = all.where((e) => e.approved_at != null && e.picked_up_at == null).toList();
    past_orders = all.where((e) => e.picked_up_at != null || e.delivered_at != null || e.declined_at != null).toList();
      // print(new_orders);

    });
  }
  acceptOrder({Order order}) async {
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/accept-order',
        headers: {
          'Content-Type': 'application/json',

        },
    body: json.encode({
      'order_id': order.id,
      'location_id': location_id
    }));
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('You accepted this order'),
    ));

 
   await initializePrinter(printIpAddress);
     final ByteData data = await rootBundle.load('assets/images/qr-logo.png');
  final Uint8List imgBytes = data.buffer.asUint8List();
  final img.Image image = img.decodeImage(imgBytes);
  // printer.image(image);
    printer.text('ORDERLIVERY ORDER #${order.id.toLowerCase()}', styles: PosStyles(align: PosAlign.center, bold: true));
   printer.text('Ordered by: ${order.customer_name}', linesAfter: 1, styles: PosStyles(bold: true));
    printer.text('${DateFormat().format(order.createdAt.toLocal())}', linesAfter: 2);
    
  printer.text('Items:', styles: PosStyles(underline: true, align: PosAlign.left), linesAfter: 1);
  var count = 1;
   order.items.forEach((element) {
     printItem(element, count);
     count += 1;
   });
      printer.text('ORDER TOTAL: \$${order.food_total.toStringAsFixed(2)}');
      printer.feed(2);
  printer.cut();
  printer.disconnect();
 
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
      await getOrders(location_id: location_id);
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

class OrderListItem {

  int id;

  // backend
  String backend_id;

  // ref
  int list_id;

  // from backend
  String name;

  // from backend
  double price;

  // user-defined
  int quantity;

  OrderListItem({
    this.id,
    this.backend_id,
    this.list_id,
    this.name,
    this.price,
    this.quantity
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    double price  = json['price'].runtimeType == int ? json['price'].toDouble() : json['price'] as double;
    return OrderListItem(
      id: json['id'] as int,
      backend_id: json['backend_id'] as String,
      list_id: json['list_id'] as int,
      name: json['name'] as String,
      price: price,
      quantity: json['quantity'] as int
    );
  }

}

class OrderList {
  // from backend
  String backend_id;
   int id;
  int item_id;
  String name;
  List<OrderListItem> items;


 OrderList({
    this.id,
    this.backend_id,
    this.name,
    this.item_id,
    this.items
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    Iterable items = json['items'];
    return OrderList(
      id: json['id'] as int,
      backend_id: json['backend_id'] as String,
      name: json['name'] as String,
      item_id: json['item_id'] as int,
      items: items.map((e) => OrderListItem.fromJson(e)).toList()
    );
  }

}
class OrderItem {
  String name;
  int quantity;
  double flat_price;
  String special_instructions;
  List<OrderList> lists;


  OrderItem({
    this.name, this.quantity, 
    this.flat_price, this.special_instructions,
    this.lists
    });


  factory OrderItem.fromJson(Map<String, dynamic> json) {

    Iterable lists = json['lists'];
    double convertToDouble(dynamic value) {
      if (value is int) {
        return value.toDouble();
      } else {
        return value;
      }
    }

    return OrderItem(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        flat_price: convertToDouble(json['flat_price']),
        special_instructions: json['special_instructions'] as String,
        lists: lists.map((e) => OrderList.fromJson(e)).toList()
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
  DateTime createdAt;
  String customer_name;
  DateTime orderedAt;


  Order({
    this.orderedAt,
    this.customer_name,
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
    this.cooked_at,
    this.createdAt
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
      return actualDate.toLocal();
    }
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    Iterable _items = json['items'];
    return Order(
      orderedAt: json['createdAt'] != null ? getDartDateFromNetUTC(json['createdAt'] as String) : null,
      customer_name: json['customer_name'] as String,
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
        createdAt: json['createdAt'] != null ? getDartDateFromNetUTC(
            json['createdAt'] as String) : null,
      items: _items.map((e) => OrderItem.fromJson(e)).toList(),
      tax: convertToDouble(json['tax']),
      grand_total: convertToDouble(json['grand_total']),
      tip: convertToDouble(json['tip']),
      food_total: convertToDouble(json['food_total']),
      service_fee: convertToDouble(json['service_fee']),
      discount_amount: json['discount_amount'],
      id: json['_id'] as String
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();