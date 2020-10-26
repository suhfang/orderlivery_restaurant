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
import 'package:google_fonts/google_fonts.dart';
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
      final textTheme = Theme.of(context).textTheme;

      Future.delayed(Duration(milliseconds: 1000), () async {
        firebaseCloudMessaging_Listeners();
      });

      return MaterialApp(
          // navigatorKey: navigatorKey,
        title: 'Restaurant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            bodyText1: GoogleFonts.montserrat(textStyle: textTheme.bodyText1),
          ),
        ),
        home: InitPage()
      );
  }
}
