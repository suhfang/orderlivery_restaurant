import 'dart:convert';
import 'dart:io';

import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/init.dart';
import 'package:Restaurant/location_hub.dart';
import 'package:Restaurant/profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.


  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();
    if (Platform.isAndroid) Android_Permission();

    _firebaseMessaging.getToken().then((token) {
      print(token);
      Constants.messagingToken = token;
      registerMessagingToken(token);
    });

    if (Constants.messagingToken.isEmpty) {
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print(message);
          print('app onMessage');
//          FlutterRingtonePlayer.play(
//            android: AndroidSounds.notification,
//            ios: IosSounds.glass,
//            looping: true, // Android only - API >= 28
//            volume: 0.1, // Android only - API >= 28
//            asAlarm: false, // Android only - all APIs
//          );
//          if (!Constants.isOnOrdersPage) {
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) => LocationHubPage(notificationData: message,))
            );

//          }
        },
        onResume: (Map<String, dynamic> message) async {
          print(message);
          print('app onResume');
//          FlutterRingtonePlayer.play(
//            android: AndroidSounds.notification,
//            ios: IosSounds.glass,
//            looping: true, // Android only - API >= 28
//            volume: 0.1, // Android only - API >= 28
//            asAlarm: false, // Android only - all APIs
//          );
//          if (!Constants.isOnOrdersPage) {
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) => LocationHubPage(notificationData: message,))
            );

//          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print(message);
//          FlutterRingtonePlayer.play(
//            android: AndroidSounds.notification,
//            ios: IosSounds.glass,
//            looping: true, // Android only - API >= 28
//            volume: 0.1, // Android only - API >= 28
//            asAlarm: false, // Android only - all APIs
//          );
  print('app onLaunch');
  navigatorKey.currentState.push(
  MaterialPageRoute(builder: (_) => LocationHubPage(notificationData: message,))
  );
},
);
}
}

void registerMessagingToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String authToken = prefs.getString('token') ?? '';
  if (authToken.isNotEmpty) {
    Map jsonMap = {
      'firebase_messaging_token': token
    };
    print(jsonMap);
    print(authToken);
    final response = await http.post(Constants.apiBaseUrl + '/restaurants/set-firebase-messaging-token', body: json.encode(jsonMap), headers: {
      'token': authToken,
      'Content-Type': 'application/json'
    });
    print(response.statusCode);
  }

}




void iOS_Permission() async {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
//        _getCurrentLocation();
    });

  }

  void Android_Permission() async {
//      _getCurrentLocation();
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(milliseconds: 1000), () async {
      firebaseCloudMessaging_Listeners();
    });

    return MaterialApp(
        navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitPage()
    );
  }
}
