

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/connect_printer.dart';
import 'package:Restaurant/notification.dart';
import 'package:Restaurant/printer_helper.dart';
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
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:line_icons/line_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:http/http.dart' as http;
import 'package:wakelock/wakelock.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'dart:typed_data';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:convert' show utf8, base64;
import 'package:socket_io_client/socket_io_client.dart' as IO;

String encryptString(String id) => base64.encode(utf8.encode(id));

String decryptString(String encoded) => utf8.decode(base64.decode(encoded));

class LocationHubPage extends StatefulWidget {
  Map<String, dynamic> notificationData;
   LocationHubPage({this.notificationData});
  _LocationHubPageState createState() => _LocationHubPageState();
}

class CartItem {
  String name;
  String price;
  double quantity;
  String pricingType;
  CartItem({this.name, this.price, this.quantity, this.pricingType});
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
  List<CartItem> itemsToBuy = [];
  List<Order> newOrders = [];
  List<Order> pastOrders = [];
  List<Order> currentOrders = [];
  List<Order> orders = [];
  String orderId;
  double orderTotal;
  Timer timer;
  AppUpdateInfo _updateInfo;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool connected = false;
  bool flexibleUpdateAvailable = false;
  AppLifecycleState notification;
  double port = 9100;
  NetworkPrinter printer;
  bool hasPrintedAlready = false;
  Timer socketTimer;
  IO.Socket socket;
  bool _allowing = false;
  String locationId;
  String grossEarnings = 0.toDouble().toStringAsFixed(2);
  UniqueKey focusDetectorKey = UniqueKey();
  bool bottomContainerShows = false;
  Printer localPrinter;


  Future<void> checkForUpdate() async {
    if (Platform.isAndroid) {
      InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        print('found an update here it is: $_updateInfo');
      });
    }).catchError((e) => _showError(e));
    }
  }

  void _showError(dynamic exception) {
    if (Platform.isAndroid)
      Fluttertoast.showToast(msg: exception.toString(), backgroundColor: Colors.red, textColor: Colors.white);
  }

  @override
  void dispose() {
    handleWakeLock();
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    timer = null;
    updateTimer?.cancel();
    updateTimer = null;
    super.dispose();
  }

void resume() async {
    reconnect();
    await checkForUpdate();
    if (Platform.isAndroid)
      if(_updateInfo?.updateAvailable == true) 
        await InAppUpdate.performImmediateUpdate().catchError((e) => _showError(e));
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      notification = state;
    });
    notification == AppLifecycleState.resumed ? resume() : socket.disconnect();
  }

  void reconnect() async {   
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    final response = await http.get(
      '${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
      String id = json.decode(response.body)['location_id'] as String;
      await getAcceptanceStatus(location_id: id);
      _allowing == true ? 
      socket.connect() : 
      Future.delayed(Duration(milliseconds: 500), 
      () => LocalNotification.shared.showNotification(
        title: 'Offline notice', body: 'Toggle the switch to start accepting orders »'));  
      getOrders(locationId: locationId);
  }

Future<bool> initializePrinter(String ip) async {
  const PaperSize  paper = PaperSize.mm80;
  final profile = await CapabilityProfile.load();
  printer = NetworkPrinter(paper, profile);
  var res = await connectPrinter(ip);
  return res;
} 

Future<bool> connectPrinter(String ip) async {
  final PosPrintResult res = await printer.connect(ip, port: 9100);
  bool val = res == PosPrintResult.success;
   if (!val) 
    Fluttertoast.showToast(
      backgroundColor: Colors.red, 
      msg: 'Could not connect to the printer at $ip');
  return res == PosPrintResult.success;
}

void printItem(OrderItem item, int count) async {

  printer.text(
    '${item.quantity} x ${item.name}', 
    linesAfter: 1, 
    styles: PosStyles(codeTable: 'CP1252', 
    align: PosAlign.center), 
    containsChinese: true);

  if (item.special_instructions != null && item.special_instructions.isNotEmpty) {
    printer.feed(1);
    printer.text('Special instructions: ', linesAfter: 1, styles: PosStyles(bold: true));
    printer.text('${item.special_instructions}', linesAfter: 1);
    printer.feed(1);
  }

  item.lists.forEach((element) {
    printer.text(
      '${element.name}:', 
    linesAfter: 1, 
    styles: PosStyles(align: PosAlign.center));

    element.items.forEach((elem) {
      if (elem.quantity != 0) 
        printer.text('${elem.quantity} x ${elem.name}', 
        linesAfter: 1, 
        styles: PosStyles(align: PosAlign.center)); 
      else
        printer.text('${elem.name}', linesAfter: 1, styles: PosStyles(align: PosAlign.center)); 
    });
    printer.feed(1);
  });

  printer.text('------------------------------------------', linesAfter: 1, styles: PosStyles(align: PosAlign.center));
}

void blinkLights() async {
  if (newOrders.isNotEmpty)
    await FlutterRingtonePlayer.playNotification();
}

FlutterLocalNotificationsPlugin fltrNotification;
  Future showNotification({String title, String body}) async {
    var androidDetails = new AndroidNotificationDetails(
      "orderlivery_restaurant_channel_id", 
      "orderlivery_restaurant_channel_name", 
      "Orderlivery restaurant channel description", 
      importance: Importance.max);
    var iOSDetails = new IOSNotificationDetails();
    var generalNotificationDetails = new NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await fltrNotification.show((new Random()).nextInt(100), title, body, generalNotificationDetails);
  }

  getLocationId() async  {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    final response = await http.get(
      '${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
   _firebaseMessaging.getToken().then((value) async {
     setState(() {
       locationId = json.decode(response.body)['location_id'] as String;
     });
     getAcceptanceStatus(location_id: locationId);
     getOrders(locationId: locationId);
      if (locationId != null) {
        String deviceId = await _getId();
        await http.post(
          '${Constants.apiBaseUrl}/restaurant_locations/set-firebase-messaging-token', 
          headers: {
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'token': value,
            'location_id': locationId,
            'device_id': deviceId
          }));
      }
     });
      WidgetsBinding.instance.addPostFrameCallback((_) => initPlatformState());
    }

  Timer updateTimer;
  @override
  void initState() {
    getLocationId();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(Duration(milliseconds: 2000), (Timer t) => blinkLights());
    updateTimer = Timer.periodic(Duration(seconds: 3600), (Timer t) => fetchUpdates());
    handleNotifications();
    Wakelock.enable();
    var androidInitialize = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = new IOSInitializationSettings();
    var initializationSetings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification.initialize(initializationSetings, onSelectNotification: (String s) async => print(s));
    connect();
  }

  fetchUpdates() async {
    await checkForUpdate();
    if(_updateInfo?.updateAvailable == true) {
      await InAppUpdate.performImmediateUpdate().catchError((e) => _showError(e));
    }
  }

  runReconnectLoop() async {
    socketTimer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      if (connected == false) {
        bool allowing;
        if (locationId == null)
          await getLocationId();
         allowing = await getAcceptanceStatus(location_id: locationId);
        if (allowing == true && connected == false) {
          setAcceptingStatus(value: true, locationId: locationId);
        } 
      }
    });
  } 

  void initSocket() async {
    String id = await getLocationAndSendData();
    try {
       socket = IO.io('${Constants.apiBaseUrl}',
         <String, dynamic>{'transports': ['websocket']}
      );
      socket.onConnectError((_) => setState(() {
        connected = false;
      }));
      socket.onDisconnect((data) async {
        setState(() {
          connected = false;
          _allowing = false;
        });
        runReconnectLoop();
        Fluttertoast.showToast(msg: 'Please toggle the switch to start accepting orders or Contact Support');
        if (locationId != null)
          setAcceptingStatus(value: false, locationId: locationId);
        else {
          await getLocationId();
          setAcceptingStatus(value: false, locationId: locationId);
        }
      });
      socket.onConnect((data) async {
        setState(() {
          connected = true;
          socketTimer?.cancel();
          socketTimer = null;
        });
        socket.emit('/restaurant_location_connected', json.encode({
          'id': id,
          'user_type': 'restaurant_location'
        }));
      });
      if (_allowing == true) socket.connect();
   } catch (e) {
       print('error socket');
   }
}

  Future<String> getLocationAndSendData() async  {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
      final response = await http.get(
        '${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
      String id = json.decode(response.body)['location_id'] as String;
      if (id != null) {
        await getAcceptanceStatus(location_id: id);
        return id;
      }
      return null;
  }

  connect()  {
   initSocket();
  }

  void handleNotifications() async {
     _firebaseMessaging.configure(
       onMessage: (Map<String, dynamic> message) async {
         String title = '${message['notification']['title']}';
         String body = '${message['notification']['body']}';
         body.contains('was picked up') ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LocationHubPage())) : LocalNotification.shared.showNotification(title: title, body: body);
         getOrders(locationId: locationId); 
       },
       onResume: (Map<String, dynamic> message) async { },
       onLaunch: (Map<String, dynamic> message) async { },
     );
  }


  setEarnings() {
    setState(() {
      if (orders.isNotEmpty) 
        grossEarnings = orders
        .where((a) => a.approved_at != null)
        .map((e) => e.food_total)
        .toList()
        .reduce((a, b) => (a + b))
        .toStringAsFixed(2);
    });
  }
  handleWakeLock() async {
    if (await Wakelock.enabled)
      Wakelock.disable();
  }

 initPlatformState() async {
   FlutterStatusbarcolor.setNavigationBarColor(Colors.orange);
   FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
   await PrinterProvider.shared.open('printer.db');
   getDefaultPrinter();
 }

  void getDefaultPrinter() async {
    var k = await PrinterProvider.shared.getDefaultPrinter();
    if (k != null) 
      setState(() {
        localPrinter = k;
        print(localPrinter);
      });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:  DefaultTabController(
        length: 3,
        child: FocusDetector(
          key: focusDetectorKey,
          onFocusGained: () async {
            await getLocationId();
            getDefaultPrinter();
            await checkForUpdate();
            if(_updateInfo?.updateAvailable == true) {
              await InAppUpdate.performImmediateUpdate().catchError((e) => _showError(e));
            }
          },
          child: Scaffold(
        
        key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Today\'s Incoming Orders', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        centerTitle: true,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                ListView(
                  children: [
                    ListTile(
                      title: Text('Orders', style: TextStyle(color: Colors.black),),
                      leading: Icon(LineIcons.newspaper_o, color: Colors.orange,),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                     ListTile(
                      title: Text('Connect Printers', style: TextStyle(color: Colors.black),),
                      leading: Icon(LineIcons.print, color: Colors.orange,),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ConnectPrinterPage()
                        ));
                      },
                    ),
                    ListTile(
                        title: Text('Log Out',style: TextStyle(color: Colors.black),),
                        leading: Icon(LineIcons.sign_out, color: Colors.orange,),
                        onTap: () async {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SpinKitRing(
                                        color: Colors.white,
                                        size: 50.0,
                                        lineWidth: 2)
                                    ],
                                  ));
                            });
                          SharedPreferences prefs  = await SharedPreferences.getInstance();
                          final response = await http.get('${Constants.apiBaseUrl}/restaurant_locations/get-location-id?token=${prefs.getString('token')}');
                          String locationId = json.decode(response.body)['location_id'] as String;
                          var url = Constants.apiBaseUrl + '/restaurant_locations/unregister-messaging-token';
                          String deviceId = await _getId();
                          await http.post(url,
                            headers: {
                              "Content-Type": "application/json",
                            },
                            body: json.encode({
                              'device_id': deviceId,
                              'location_id': locationId
                            }));
                          Navigator.pop(context);
                          if (locationId == null) 
                            await getLocationId();
                          await setAcceptingStatus(value: false, locationId: locationId);
                          await prefs.remove('token');
                          await prefs.remove('is_location');
                          await prefs.remove('is_restaurant');
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => AuthPage(loginTab: true,)));
                        }
                    ),
                  ],
                )
              ],
            ),
          ),
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
                  Text('Accepting Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  CupertinoSwitch(
                    activeColor: Colors.orange,
                    value: _allowing,
                    onChanged: (bool newValue) async {
                      if (locationId != null) {
                        bool result = await setAcceptingStatus(value: newValue, locationId: locationId);
                        setState(()  {
                          _allowing = result;
                        });
                        if (!_allowing) {
                          Fluttertoast.showToast(
                            msg: 'You are currently not accepting new orders!',
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_LONG);
                          await HapticFeedback.heavyImpact();
                        } else {
                           Fluttertoast.showToast(
                            msg: 'You are now accepting orders!',
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_LONG);
                          await HapticFeedback.heavyImpact();
                        }
                      }
                    },
                  ) 
                ],
              ),
            ),
            SizedBox(height: 20,),
            Text('Total Gross earnings for the day (USD)'),
            Text(orders.isNotEmpty ? '\$$grossEarnings' : '\$0.00',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold
                )),
            SizedBox(height: 40,),
            TabBar(
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.black,
              tabs: [
                Tab(
                  child:  newOrders.isNotEmpty ?
                  Badge(
                    badgeColor: Colors.brown,
                    badgeContent: Container(
                      height: 25, width: 25, 
                      child: Center(
                        child: Text(newOrders.length > 99 ? '99+' : '${newOrders.length}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),),
                      ),
                    child: Row(
                      children: [
                          Expanded(
                            child: BlinkingButton(
                              child: Text('NEW', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12),),
                            )
                        )
                      ],
                    ) 
                  )
                  :  Container(
                    width: 150,
                    child: Text('NEW', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ),
                Tab(
                  child: currentOrders.isNotEmpty ?
                  Badge(
                      child: Container(
                        width: 150,
                        child: Text('IN-PROGRESS', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                  ) : Container(
                    width: 150,
                    child: Text('IN-PROGRESS', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ),
                Tab(
                  child:  pastOrders.isNotEmpty ?
                  Badge(
                      child: Container(
                        width: 150,
                        child: Text('PAST', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                  ) : Container(
                    width: 150,
                    child: Text('PAST', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                 Container(
                    child: newOrders.isEmpty ?
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LineIcons.frown_o, size: 25),
                          SizedBox(height: 5),
                          Text('No new orders were found', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ) : ListView.separated(
                      itemBuilder: (context, index) {
                        final order = newOrders[index];
                        return Container(
                          child: Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                   Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ordered at:'),
                                      Text('${DateFormat().format(order.createdAt.toLocal())}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Customer\'s name:'),
                                      Text('${order.customer_name}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Order Type:'),
                                      Text('${order.order_type == 'delivery' ? 'Delivery' : 'Pickup'}')
                                    ],
                                  ),
                                  Divider(height: 50,),
                                  Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                  SizedBox(height: 20),
                                  ...(
                                    order.items.map((item) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(height: 10),
                                          // Divider(color: Colors.black,),
                                          Container(
                                             padding: EdgeInsets.only(left: 10, right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xF1F1F1F1),
                                               boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                 item.special_instructions != null && item.special_instructions.isNotEmpty ?
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Special instructions: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 10,),
                                                        Text('${item.special_instructions}'),
                                                      ],
                                                    ) 
                                                  ): SizedBox(),
                                                  SizedBox(height: 10),
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text('${item.quantity} x ${item.name}'),
                                                    trailing: item.flat_price != null ?
                                                    Text('\$${item.flat_price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)) :
                                                    Text('', style: TextStyle(fontWeight: FontWeight.bold)), 
                                                  ),
                                                  ...(
                                                    item.lists.map((list) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 20,),
                                                        child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('${list.name}: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                                          SizedBox(height: 20,),
                                                          ...(
                                                            list.items.map((listItem) {
                                                              if (listItem.quantity != 0) {
                                                                return Text('${listItem.quantity} x ${listItem.name}');
                                                              } else {
                                                                return Text('${listItem.name}');
                                                              }
                                                            }).toList()
                                                          )
                                                        ],
                                                      )
                                                      );
                                                    }).toList()
                                                  ),
                                              ],
                                            )
                                          )
                                        ],
                                      );
                                    }).toList()
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('Food total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      trailing: Text('\$${order.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    )
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            acceptOrder(order: order);
                                          },
                                          child: BlinkingButton(
                                            speed: 1000,
                                            child: Container(
                                            
                                              height: 40,
                                              child: Center(
                                                child: Text('Accept Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.1),
                                                      spreadRadius: 1,
                                                      blurRadius: 3,
                                                      offset: Offset(0, 3), // changes position of shadow
                                                    ),
                                                ]
                                              ),
                                            ),
                                          )
                                        )
                                      ),
                                      SizedBox(width: 20,),
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
                                                                 Text('Are you sure you want to decline this order?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)
                                                               ],
                                                             ),
                                                           ),
                                                           Expanded(
                                                             child:  Row(
                                                               children: [
                                                                 Expanded(
                                                                     child: GestureDetector(
                                                                       onTap: () async {
                                                                         declineOrder(orderId: order.id);
                                                                         await getLocationId();
                                                                         Navigator.pop(context);
                                                                         Fluttertoast.showToast(msg: 'You declined this order!');
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
                                                                 SizedBox(width: 20),
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
                                          child: Container(
                                            height: 40,
                                            child: Center(
                                              child: Text('Decline Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),),
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(30),
                                               boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                               ]
                                            ),
                                          ),
                                        )
                                      )
                                    ],
                                  )
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                            )
                        );
                      },
                      itemCount: newOrders.length,
                      separatorBuilder: (context, index) {
                        return Divider(thickness: 50, color: Color(0xF1F1F1F1), height: 50,);
                      }
                    )
                  ),
                  Container(
                    child: currentOrders.isEmpty ?
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LineIcons.frown_o, size: 25),
                          SizedBox(height: 5),
                          Text('No current orders were found', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ) :
                    ListView.separated(
                      itemBuilder: (context, index) {
                        final order = currentOrders[index];
                        return Container(
                          child: Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                               Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ordered at:'),
                                      Text('${DateFormat().format(order.createdAt.toLocal())}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Customer\'s name:'),
                                      Text('${order.customer_name}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Order Type:'),
                                      Text('${order.order_type == 'delivery' ? 'Delivery' : 'Pickup'}')
                                    ],
                                  ),
                                  Divider(height: 50,),
                                  Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                  SizedBox(height: 20),
                                  ...(
                                    order.items.map((item) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(height: 10),
                                          // Divider(color: Colors.black,),
                                          Container(
                                             padding: EdgeInsets.only(left: 10, right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xF1F1F1F1),
                                               boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                 item.special_instructions != null && item.special_instructions.isNotEmpty ?
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Special instructions: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 10,),
                                                        Text('${item.special_instructions}'),
                                                      ],
                                                    ) 
                                                  ): SizedBox(),
                                                  SizedBox(height: 10),
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text('${item.quantity} x ${item.name}'),
                                                    trailing: item.flat_price != null ?
                                                    Text('\$${item.flat_price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)) :
                                                    Text('', style: TextStyle(fontWeight: FontWeight.bold))
                                                  ),
                                                  ...(
                                                    item.lists.map((list) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 20,),
                                                        child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('${list.name}: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                                          SizedBox(height: 20,),
                                                          ...(
                                                            list.items.map((listItem) {
                                                              if (listItem.quantity != 0) {
                                                                return Text('${listItem.quantity} x ${listItem.name}');
                                                              } else {
                                                                return Text('${listItem.name}');
                                                              }
                                                            }).toList()
                                                          )
                                                        ],
                                                      )
                                                      );
                                                    }).toList()
                                                  ),
                                              ],
                                            )
                                          )
                                        ],
                                      );
                                    }).toList()
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('Food total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      trailing: Text('\$${order.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    )
                                  ),
                                 Row(
                                      children: [
                                        Expanded(
                                            child: order.approved_at != null && order.cooked_at == null ?
                                            GestureDetector(
                                              onTap: () async {
                                                await finishOrder(orderId: order.id);
                                              },
                                              child: BlinkingButton(
                                                speed: 1000,
                                                child: Container(
                                                
                                                height: 45,
                                                child: Center(
                                                  child: Text('Ready for Pickup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.brown,
                                                    borderRadius: BorderRadius.circular(30),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.1),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset: Offset(0, 3), // changes position of shadow
                                                      ),
                                                    ]
                                                ),
                                              ),
                                              )
                                            ) :
                                           GestureDetector(
                                             onTap: () async {
                                               if (order.order_type == 'delivery') {
                                                 bottomContainerShows = true;
                                                await showCupertinoModalPopup(context: context, builder: (context) {
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
                                                                   padding: EdgeInsets.all(50),
                                                                   child: Icon(LineIcons.close, size: 50),
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
                                                                       data: encryptString(order.id),
                                                                       foregroundColor: Colors.black,
                                                                       version: QrVersions.auto,
                                                                       size: 300.0,
                                                                     ),
                                                                     decoration: BoxDecoration(
                                                                        // color: Colors.orange,
                                                                      //  borderRadius: BorderRadius.circular(30),
                                                                     ),
                                                                   ),
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
                                                if (locationId == null) {
                                                  await getLocationId();
                                                  getOrders(locationId: locationId);
                                                } else 
                                                  getOrders(locationId: locationId);
                                               } else {
                                                await confirmPickup(order_id: order.id);
                                               }
                                             },
                                             child:  Container(
                                               height: 45,
                                               child: Center(
                                                 child: Text(order.order_type == 'delivery' ? 'Hand to Envoy' : 'Hand to Customer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                                               ),
                                               decoration: BoxDecoration(
                                                   color: Colors.orange,
                                                   borderRadius: BorderRadius.circular(30)
                                               ),
                                             ),
                                           )
                                        ),
                                      ],
                                    ) ,
                                    SizedBox(height: 10,),
                                      GestureDetector(
                                        onTap: () {
                                          printOrder(order: order);
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context).size.width-80,
                                          decoration: BoxDecoration(
                                            color: Color(0xF1F1F1F1),
                                            borderRadius: BorderRadius.circular(30),
                                             boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                          ),
                                          child: Center(
                                            child: Text('Print this Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)
                                          ),
                                        )
                                      ),
                                      SizedBox(height: 10,),
                                      order.cooked_at == null ?
                                        GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(context: context, builder: (context) {
                                            return Container(
                                              padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
                                              height: 150,
                                              child: Column(
                                                children: [
                                                  Text('Are you sure want to cancel this order because you were out of stock of an item?', textAlign: TextAlign.center,),
                                                  SizedBox(height: 20,),
                                                  Row(
                                                    children: [
                                                     Expanded(
                                                       child:  GestureDetector(
                                                         onTap: () {
                                                           outOfStock(order: order);
                                                         },
                                                         child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: Colors.orange,
                                                          borderRadius: BorderRadius.circular(30)
                                                        ),
                                                        child: Center(
                                                          child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold,))
                                                        )
                                                      ),
                                                       )
                                                     ),
                                                      SizedBox(width: 20),
                                                      Expanded(
                                                       child:  GestureDetector(
                                                         onTap: () {
                                                           Navigator.pop(context);
                                                         },
                                                         child: Container(
                                                        height: 40,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xF1F1F1F1),
                                                          borderRadius: BorderRadius.circular(30)
                                                        ),
                                                        child: Center(
                                                          child: Text('No', style: TextStyle(fontWeight: FontWeight.bold,))
                                                        )
                                                      ),
                                                       )
                                                     ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            );
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: MediaQuery.of(context).size.width-80,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(30),
                                             boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                          ),
                                          child: Center(
                                            child: Text('Cancel Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                                          ),
                                        )
                                      ) : SizedBox()
                                     ],
                              ),
                              padding: EdgeInsets.all(20),
                            )
                        );
                      },
                      itemCount: currentOrders.length,
                      separatorBuilder: (context, index) {
                        return Divider(thickness: 50, color: Color(0xF1F1F1F1), height: 50,);
                      }
                    )
                  ),
                 Container(
                    child: pastOrders.isEmpty ?
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LineIcons.frown_o, size: 25),
                          SizedBox(height: 5),
                          Text('No past orders were found', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ) : 
                    ListView.separated(
                      itemBuilder: (context, index) {
                        final order = pastOrders[index];
                        return Container(
                          child: Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                  Text('Order #${order.id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ordered at:'),
                                      Text('${DateFormat().format(order.createdAt.toLocal())}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Customer\'s name:'),
                                      Text('${order.customer_name}')
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                   Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Order Type:'),
                                      Text('${order.order_type == 'delivery' ? 'Delivery' : 'Pickup'}')
                                    ],
                                  ),
                                  Divider(height: 50,),
                                  Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                  SizedBox(height: 20),
                                  ...(
                                    order.items.map((item) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(height: 10),
                                          // Divider(color: Colors.black,),
                                          Container(
                                            padding: EdgeInsets.only(left: 10, right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Color(0xF1F1F1F1),
                                               boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                 item.special_instructions != null && item.special_instructions.isNotEmpty ?
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('Special instructions: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                        SizedBox(height: 10,),
                                                        Text('${item.special_instructions}'),
                                                      ],
                                                    ) 
                                                  ): SizedBox(),
                                                  SizedBox(height: 10),
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text('${item.quantity} x ${item.name}'),
                                                    trailing: item.flat_price != null ?
                                                    Text('\$${item.flat_price.toStringAsFixed(2)}') :
                                                    Text('')
                                                  ),
                                                  ...(
                                                    item.lists.map((list) {
                                                      return Padding(
                                                        padding: EdgeInsets.only(top: 20,),
                                                        child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('${list.name}: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                                                          SizedBox(height: 20,),
                                                          ...(
                                                            list.items.map((listItem) {
                                                              if (listItem.quantity != 0) {
                                                                return Text('${listItem.quantity} x ${listItem.name}');
                                                              } else {
                                                                return Text('${listItem.name}');
                                                              }
                                                            }).toList()
                                                          )
                                                        ],
                                                      )
                                                      );
                                                    }).toList()
                                                  ),
                                              ],
                                            )
                                          )
                                        ],
                                      );
                                    }).toList()
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('Food total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                      trailing: Text('\$${order.food_total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    )
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(20),
                            )
                        );
                      },
                      itemCount: pastOrders.length,
                      separatorBuilder: (context, index) {
                        return Divider(thickness: 50, color: Color(0xF1F1F1F1), height: 50,);
                      }
                    )
                    
                  ),
                ],
              ),
            )
       
            )
         ],
        )
  
        )    )
 
        )   
      )
    ));
  }


outOfStock({Order order}) async {
  final response = await http.post(
    '${Constants.apiBaseUrl}/restaurant_locations/out-of-stock', 
  headers: {
    'Content-Type': 'application/json'
  },
  body: json.encode({
    'order_id': order.id
  }));
  Navigator.pop(context);
  getOrders(locationId: locationId);
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

  getOrders({String locationId}) async {
    var date = DateTime.now();
    int today = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().millisecondsSinceEpoch;
    final response = await http.post('${Constants.apiBaseUrl}/restaurant_locations/get-orders', headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'location_id': locationId,
      'start_date': today
    }));
    Iterable _orders = json.decode(response.body);
    var all = _orders.map((e) => Order.fromJson(e)).toList();
     all.sort((a,b) {
      return a.createdAt.compareTo(b.createdAt);
    });
    setState(() {
      orders = all;
      newOrders = all.where((e) => e.approved_at == null && e.declined_at == null).toList();
      currentOrders = all.where((e) => e.approved_at != null && e.picked_up_at == null).toList();
      pastOrders = all.where((e) => e.picked_up_at != null || e.delivered_at != null || e.declined_at != null).toList();
    });
    setEarnings();
  }


  acceptOrder({Order order}) async {
    await http.post(
      '${Constants.apiBaseUrl}/restaurant_locations/accept-order',
        headers: {
          'Content-Type': 'application/json'
        },
      body: json.encode({
        'order_id': order.id,
        'location_id': locationId,
      }));
    Fluttertoast.showToast(msg: 'You accepted this order');
      if (locationId != null) 
        getOrders(locationId: locationId);
      printOrder(order: order);
  }

  printOrder({Order order}) async {
     
   var defaultPrinter = await PrinterProvider.shared.getDefaultPrinter();
   print('default printer: $defaultPrinter');
   if (defaultPrinter != null) {
    var initialized = await initializePrinter(defaultPrinter.ip);
    if (initialized) {
        final ByteData data = await rootBundle.load('assets/images/thermal-logo.png');
        final Uint8List _ = data.buffer.asUint8List();
        printer.text('ORDERLIVERY ORDER', styles: PosStyles(align: PosAlign.center, bold: true,), linesAfter: 1);
        printer.text('Order Type: ${order.order_type == 'delivery' ? 'Delivery' : 'Pickup'}', linesAfter: 1, styles: PosStyles(bold: true));
        printer.text('Customer\'s name: ${order.customer_name}', linesAfter: 1, styles: PosStyles(bold: true));
        printer.text('${DateFormat().format(order.createdAt.toLocal())}', linesAfter: 2);
        printer.text('Items:', styles: PosStyles(underline: true, align: PosAlign.left), linesAfter: 1);
        var count = 1;
        order.items.forEach((element) {
          printItem(element, count);
          count += 1;
        });
        printer.text('ORDER TOTAL: \$${order.food_total.toStringAsFixed(2)}', linesAfter: 2);
        printer.feed(2);
        printer.cut();
        printer.disconnect();
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Could not print this order. Please check printer connection!',
        backgroundColor: Colors.red,
        textColor: Colors.white);
    }
  }

Future<Uint8List> toQrImageData(String text) async {
try {
    final image = await QrPainter(
      data: text,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.black,
      emptyColor: Colors.white,
    ).toImage(300);
    final png = await image.toByteData(format: ImageByteFormat.png);
    return png.buffer.asUint8List();
  } catch (e) {
    throw e;
  }
}

 confirmPickup({String order_id}) async {
    await http.post('${Constants.apiBaseUrl}/restaurant_locations/confirm-customer-pickup',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': order_id,
          'location_id': locationId
        }));
    Fluttertoast.showToast(msg: 'You marked this order as picked up by the customer');
    if (locationId != null) 
      await getOrders(locationId: locationId);
  }

  finishOrder({String orderId}) async {
    await http.post('${Constants.apiBaseUrl}/restaurant_locations/finish-order',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
          'location_id': locationId
        }));
    Fluttertoast.showToast(msg: 'You marked this order as ready for pickup');
    if (locationId != null)
      await getOrders(locationId: locationId);
  }

  declineOrder({String orderId}) async {
    await http.post('${Constants.apiBaseUrl}/restaurant_locations/decline-order',
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_id': orderId,
          'location_id': locationId
        }));
  }

  setAcceptingStatus({bool value, String locationId}) async {
    final response = await http.post(
      '${Constants.apiBaseUrl}/restaurant_locations/set-status', headers: {
      'Content-Type': 'application/json'
    },
    body: json.encode({
      'location_id': locationId,
      'allowing_orders': value
    }));
    bool result = json.decode(response.body)['result'] as bool;
    result == true ? socket.connect() : socket.disconnect();
    return result;
  }

static AudioPlayer audioPlugin = AudioPlayer();
  Future<bool> getAcceptanceStatus({String location_id}) async {
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
   return result;
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

 class BlinkingButton extends StatefulWidget {

   final Widget child;
   final double width;
   final int speed;
   BlinkingButton({this.child, this.width, this.speed = 100});

    @override
    _BlinkingButtonState createState() => _BlinkingButtonState();
  }

  class _BlinkingButtonState extends State<BlinkingButton> with SingleTickerProviderStateMixin {

    AnimationController _animationController;

    @override
    void initState() {
      _animationController =
          new AnimationController(vsync: this, duration: Duration(milliseconds: widget.speed));
      _animationController.repeat(reverse: true);
    }
  
    @override
    Widget build(BuildContext context) {
      return Container(
        height: 40,
        child: FadeTransition(
            opacity: _animationController,
            child: Container(
                
                child: Center(
                  child: widget.child,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange,
                ),
              )
          )
      );
    }

    @override
    void dispose() {
      _animationController.dispose();
  
      super.dispose();
    }
  }