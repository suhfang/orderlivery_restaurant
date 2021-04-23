import 'dart:convert';
import 'dart:io';
import 'package:Restaurant/auth.dart';
import 'package:Restaurant/home.dart';
import 'package:Restaurant/init.dart';
import 'package:Restaurant/location_hub.dart';
import 'package:Restaurant/printer_helper.dart';
import 'package:Restaurant/profile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Restaurant/constants.dart' as Constants;
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PrinterProvider.shared.open('printer.db');
  if (Platform.isAndroid) {
    FlutterStatusbarcolor.setNavigationBarColor(Colors.white);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) 
        iOS_Permission();
    if (Platform.isAndroid)
       Android_Permission();
  }

void iOS_Permission() async {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered : $settings");
    });
  }

  void Android_Permission() async {}

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");

  @override
  Widget build(BuildContext context) {
      final textTheme = Theme.of(context).textTheme;
      Future.delayed(Duration(milliseconds: 1000), () async {
        firebaseCloudMessaging_Listeners();
      });
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.white,
            systemNavigationBarDividerColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark
        ),
        child: GetMaterialApp(
            title: 'Restaurant',
            debugShowCheckedModeBanner: false,
            theme:
            ThemeData(
                primarySwatch: Colors.orange,
                visualDensity: VisualDensity.adaptivePlatformDensity,

                textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
                  bodyText1: GoogleFonts.montserrat(textStyle: textTheme.bodyText1),
                ),
                highlightColor: Colors.transparent)
                .copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                },
              ),
            ),
            home: InitPage()
        )
      );
  }
}
